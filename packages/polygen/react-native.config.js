/**
 * @type {import('@react-native-community/cli-types').UserDependencyConfig}
 */
module.exports = {
  resolver: {
    unstable_enablePackageExports: true,
  },
  dependency: {
    platforms: {
      android: {
        packageImportPath: 'import com.callstack.polygen.PolygenPackage;',
        packageInstance: 'new PolygenPackage()',
      },
      ios: {},
    },
  },
};
