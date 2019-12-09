module.exports.removeNulls = function removeNulls(object) {
  const keys = Object.keys(object);
  keys.forEach(k => {
    if (object[k] == null) delete object[k];
    if (typeof object[k] === 'object') removeNulls(object[k]);
  });
  return object;
}