import {
  NativeModules,
} from 'react-native';

export function getPixelRGBA(filePath, x, y) {
  return new Promise((resolve, reject) => {
      NativeModules.RNPixelColor.getPixelRGBAofImage(filePath, x, y, (err, color) => {        
        if (err) {
          return reject(err);
        }
        resolve(color);
      });
  });
}

export function getPixelRGBAverage(filePath) {
  return new Promise((resolve, reject) => {
      NativeModules.RNPixelColor.getPixelRGBAverageOfImage(filePath, (err, color) => {        
        if (err) {
          return reject(err);
        }
        resolve(color);
      });
  });
}

export function getPixelRGBAPolar(filePath, angle, radius) {
  return new Promise((resolve, reject) => {
      NativeModules.RNPixelColor.getPixelRGBAPolarOfImage(filePath, angle, radius, (err, color) => {        
        if (err) {
          return reject(err);
        }
        resolve(color);
      });
  });
}

export function findAngleOfNearestColor(filePath, minAngle, maxAngle, radius, targetColor) {
  return new Promise((resolve, reject) => {
      NativeModules.RNPixelColor.findAngleOfNearestColor(filePath, minAngle, maxAngle, radius, targetColor, (err, angle) => {        
        if (err) {
          return reject(err);
        }
        resolve(angle);
      });
  });
}