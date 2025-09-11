// Test file for the Node.js test project
const { hello, greet, calculateSum } = require('./index');

describe('Hello function', () => {
  let consoleSpy;

  beforeEach(() => {
    consoleSpy = jest.spyOn(console, 'log').mockImplementation();
  });

  afterEach(() => {
    consoleSpy.mockRestore();
  });

  test('should log greeting with provided name', () => {
    hello('Alice');
    expect(consoleSpy).toHaveBeenCalledWith('Hello, Alice!');
  });

  test('should log greeting with World when no name provided', () => {
    hello();
    expect(consoleSpy).toHaveBeenCalledWith('Hello, undefined!');
  });

  test('should log greeting with empty string', () => {
    hello('');
    expect(consoleSpy).toHaveBeenCalledWith('Hello, !');
  });
});

describe('Greet function', () => {
  test('should return greeting with provided name', () => {
    const result = greet('Bob');
    expect(result).toBe('Hello, Bob!');
  });

  test('should return default greeting when name is empty', () => {
    const result = greet('');
    expect(result).toBe('Hello, World!');
  });

  test('should return default greeting when no name provided', () => {
    const result = greet();
    expect(result).toBe('Hello, World!');
  });

  test('should handle special characters in name', () => {
    const result = greet('Node.js Developer');
    expect(result).toBe('Hello, Node.js Developer!');
  });
});

describe('CalculateSum function', () => {
  test('should return sum of two positive numbers', () => {
    const result = calculateSum(2, 3);
    expect(result).toBe(5);
  });

  test('should return sum of negative numbers', () => {
    const result = calculateSum(-2, -3);
    expect(result).toBe(-5);
  });

  test('should return sum when one number is zero', () => {
    const result = calculateSum(5, 0);
    expect(result).toBe(5);
  });

  test('should handle decimal numbers', () => {
    const result = calculateSum(1.5, 2.5);
    expect(result).toBe(4);
  });
});
