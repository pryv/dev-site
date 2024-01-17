/**
 * Original source: https://github.com/gchallen/code.metalsmith-linkcheck
 * Modified so that config files aren't part of the Metalsmith source dir.
 * Not published back to the community because it's a quickfix and we don't want further responsibilities.
 */

const path = require('path');
const fs = require('fs');
const async = require('async');
const _ = require('underscore');
const cheerio = require('cheerio');
const jsonfile = require('jsonfile');
let request = require('request');
const resolvePathname = require('resolve-pathname');

request = request.defaults({ jar: request.jar() });
jsonfile.spaces = 4;

const externalPattern = /^(https?|ftp|file|data):/;
function isExternalLink (link) {
  return externalPattern.test(link);
}

const protocolIndependentPattern = /^\/\//;
function isProtocolIndependentLink (link) {
  return protocolIndependentPattern.test(link);
}

function removeFiles (files, config) {
  if (files[config.checkFile]) {
    delete (files[config.checkFile]);
  }
  if (files[config.failFile]) {
    delete (files[config.failFile]);
  }
  if (files[config.ignoreFile]) {
    delete (files[config.ignoreFile]);
  }
}

const defaults = {
  verbose: true,
  failWithoutNetwork: true,
  failMissing: false,
  cacheChecks: true,
  recheckMinutes: 1440,
  timeout: 15,
  checkFile: '.links_checked.json',
  ignoreFile: 'links_ignore.json',
  failFile: 'links_failed.json'
};

function processConfig (config) {
  config = config || {};
  config = _.extend(_.clone(defaults), config);
  if (config.processed) return config;
  config.processed = true;
  const baseDir = path.join(__dirname, '..');
  config.checkFile = path.join(baseDir, config.checkFile);
  config.ignoreFile = path.join(baseDir, config.ignoreFile);
  config.failFile = path.join(baseDir, config.failFile);

  return config;
}

function linkcheck (config) {
  return function (files, metalsmith, done) {
    config = processConfig(config);
    config.optimizeInternal = true;

    const metadata = metalsmith.metadata();
    const checkTime = metadata.date || new Date();

    const filelinks = {}; let alllinks = {};

    const htmlfiles = _.pick(files, function (file, filename) {
      return (path.extname(filename) === '.html');
    });

    let checkedLinks = {}; let ignoreLinks = []; let internalFailed = [];
    if (config.cacheChecks) {
      try {
        checkedLinks = jsonfile.readFileSync(config.checkFile);
      } catch (err) {
        // no cache
      }
    }
    try {
      ignoreLinks = jsonfile.readFileSync(config.ignoreFile);
    } catch (err) {
      console.debug('Error reading ignore file:', err);
    }

    let network = true;

    async.series([
      function (callback) {
        async.forEachOfLimit(htmlfiles, 8, function (file, filename, finished) {
          const $ = cheerio.load(file.contents);

          let allLinks = [];
          allLinks = allLinks.concat($('a:not(.link_exception a)')
            .not('.link_exception')
            .map(function () {
              return $(this).attr('href');
            }).get());
          allLinks = allLinks.concat($('img:not(.link_exception img)')
            .not('.link_exception')
            .map(function () {
              return $(this).attr('src');
            }).get());
          allLinks = allLinks.concat($('link:not(.link_exception link)')
            .not('.link_exception')
            .map(function () {
              return $(this).attr('href');
            }).get());
          allLinks = allLinks.concat($('script:not(.link_exception script)')
            .not('.link_exception')
            .map(function () {
              return $(this).attr('src');
            }).get());
          allLinks = _.reject(allLinks, function (link) {
            return ((link.indexOf('#') === 0) || (link.lastIndexOf('mailto:', 0) === 0));
          });
          allLinks = _.map(allLinks, function (link) {
            if (isProtocolIndependentLink(link)) {
              return 'http://' + link.substring(2);
            } else if (!isExternalLink(link)) {
              return resolvePathname(link, '/' + filename);
            } else {
              return link;
            }
          });
          filelinks[filename] = allLinks;
          finished();
        },
        function () {
          alllinks = _.uniq(_.flatten(_.map(filelinks, _.values)));
          callback();
        });
      },
      function (callback) {
        request.head('http://www.google.com', function (error, response, body) {
          if (error || !response || response.statusCode !== 200) {
            if (config.verbose) {
              console.log('metalsmith-linkcheck: network failure');
            }
            if (config.failWithoutNetwork) {
              removeFiles(files, config);
              done(new Error('network failure'));
              return;
            } else {
              network = false;
            }
          }
          callback();
        });
      },
      function (callback) {
        let internal = _.map(_.reject(alllinks, isExternalLink), function (e) {
          return e.toLowerCase();
        });

        if (config.optimizeInternal) {
          const filenames = _.map(_.keys(files), function (e) {
            return ('/' + e).toLowerCase();
          });
          internal = _.map(internal, function (link) {
            if (link.indexOf('#') === -1) {
              return link;
            } else {
              return link.split('#')[0];
            }
          });
          async.mapLimit(internal, 8, function (link, finished) {
            if (link.indexOf('#') !== -1) {
              finished(null, null);
            } else if (ignoreLinks.indexOf(link) !== -1) {
              finished(null, null);
            } else if (filenames.indexOf(link) !== -1) {
              finished(null, null);
            } else if ((link.indexOf('/', link.length - 1) !== -1) &&
                         (filenames.indexOf(link + 'index.html') !== -1)) {
              finished(null, null);
            } else if ((link.indexOf('/', link.length - 1) === -1) &&
                         (filenames.indexOf(link + '/index.html') !== -1)) {
              finished(null, null);
            } else if ((link.indexOf('/', link.length - 1) === -1) &&
                         (filenames.indexOf(link + '.html') !== -1)) {
              finished(null, null);
            } else {
              finished(null, link);
            }
          }, function (err, results) {
            if (err) {
              return callback(err);
            }
            internalFailed = _.reject(results, function (e) { return !e; });
            callback();
          });
        } else {
          if (!network) {
            if (config.verbose) {
              console.log('metalsmith-linkcheck: skipping external links due to network failure');
            }
            removeFiles(files, config);
            done();
            return;
          }
          async.mapLimit(internal, 8, function (link, finished) {
            if (ignoreLinks.indexOf(link) !== -1) {
              finished(null, null);
              return;
            }
            request.head(config.internalHost + link, function (error, response, body) {
              if (error || !response || response.statusCode !== 200) {
                finished(null, link);
              } else {
                finished(null, null);
              }
            });
          }, function (err, results) {
            if (err) {
              return callback(err);
            }
            internalFailed = _.reject(results, function (e) { return !e; });
            callback();
          });
        }
      },
      function (callback) {
        if (internalFailed.length > 0 && config.failMissing) {
          jsonfile.writeFileSync(config.failFile, internalFailed);
          removeFiles(files, config);
          if (config.verbose) {
            console.log('metalsmith-linkcheck: links failed; see ' + config.failFile);
          }
          done(new Error('failed links: ' + internalFailed.join()));
          return;
        }
        callback();
      },
      function (callback) {
        const external = _.filter(alllinks, isExternalLink);

        async.mapLimit(external, 8, function (link, finished) {
          if (ignoreLinks.indexOf(link) !== -1) {
            setImmediate(() => finished(null, null));
            return;
          }
          if (checkedLinks[link]) {
            const diff = checkTime - (new Date(checkedLinks[link]));
            if (diff > 0 && diff < (config.recheckMinutes * 60 * 1000)) {
              setImmediate(() => finished(null, null));
              return;
            }
          }
          const options = {
            uri: link,
            headers: {
              'User-Agent': 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.'
            },
            maxRedirects: 5,
            timeout: config.timeout * 1000
          };
          request.head(options, function (error, response, body) {
            if (error || !response || response.statusCode !== 200) {
              request.get(options, function (error, response, body) {
                if (error || !response || response.statusCode !== 200) {
                  delete (checkedLinks[link]);
                  finished(null, link);
                } else {
                  checkedLinks[link] = checkTime;
                  finished(null, null);
                }
              });
            } else {
              checkedLinks[link] = checkTime;
              finished(null, null);
            }
          });
        }, function (err, results) {
          if (err) {
            done(err);
          }
          if (config.cacheChecks) {
            jsonfile.writeFileSync(config.checkFile, checkedLinks);
          }
          const failed = _.union(internalFailed, _.reject(results, function (e) { return !e; }));
          if (failed.length > 0) {
            jsonfile.writeFileSync(config.failFile, failed, { spaces: 2 });
            if (config.verbose) {
              console.log('metalsmith-linkcheck: links failed; see ' + config.failFile);
            }
            if (config.failMissing) {
              removeFiles(files, config);
              done(new Error('failed links: ' + failed.join()));
              return;
            }
          } else {
            try {
              fs.unlinkSync(config.failFile);
            } catch (err) {}
          }
          removeFiles(files, config);
          done();
        });
      }
    ]);
  };
}

exports = module.exports = linkcheck;
exports.defaults = defaults;
exports.processConfig = processConfig;
