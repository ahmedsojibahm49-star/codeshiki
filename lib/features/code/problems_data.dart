import '../../data/models.dart';

/// One input/output example shown on a problem detail screen.
class ProblemExample {
  const ProblemExample({
    required this.input,
    required this.output,
    this.explanation = '',
  });

  final String input;
  final String output;
  final String explanation;
}

/// A practice problem from the Code tab. Each problem maps to a
/// [CodeProject] (see [ProblemsData.problemProjects]) so the editor can
/// open it directly via `/editor/<problemId>`.
class PracticeProblem {
  const PracticeProblem({
    required this.id,
    required this.title,
    required this.difficulty, // 'Easy' | 'Medium' | 'Hard'
    required this.language,
    required this.description,
    required this.examples,
    required this.constraints,
    required this.starterCode,
    required this.fileName,
    required this.tests,
    required this.runOutput,
    required this.hint,
  });

  final String id;
  final String title;
  final String difficulty;
  final String language;
  final String description;
  final List<ProblemExample> examples;
  final List<String> constraints;
  final String starterCode;
  final String fileName;
  final List<CodeTestResult> tests;
  final String runOutput;
  final String hint;
}

/// The 6 demo practice problems. Ids are prefixed `prob-` so they never
/// collide with the demo project ids in [CodeSamples] (`two-sum` exists
/// there as a finished project; `prob-two-sum` is the practice version
/// with starter code).
class ProblemsData {
  ProblemsData._();

  static const List<PracticeProblem> problems = [
    PracticeProblem(
      id: 'prob-two-sum',
      title: 'Two Sum',
      difficulty: 'Easy',
      language: 'Java',
      description:
          'Given an array of integers nums and an integer target, return the '
          'indices of the two numbers that add up to target. You may assume '
          'each input has exactly one solution, and you may not use the same '
          'element twice.',
      examples: [
        ProblemExample(
          input: 'nums = [2, 7, 11, 15], target = 9',
          output: '[0, 1]',
          explanation: 'nums[0] + nums[1] = 2 + 7 = 9.',
        ),
        ProblemExample(
          input: 'nums = [3, 2, 4], target = 6',
          output: '[1, 2]',
        ),
      ],
      constraints: [
        '2 <= nums.length <= 10^4',
        '-10^9 <= nums[i] <= 10^9',
        'Exactly one valid answer exists.',
      ],
      starterCode: '''import java.util.HashMap;
import java.util.Map;

class Solution {
    // Return indices of the two numbers that add up to target.
    public int[] twoSum(int[] nums, int target) {
        // TODO: use a HashMap for an O(n) solution.
        return new int[]{};
    }

    public static void main(String[] args) {
        Solution s = new Solution();
        int[] result = s.twoSum(new int[]{2, 7, 11, 15}, 9);
        System.out.println("Result length: " + result.length);
    }
}
''',
      fileName: 'Solution.java',
      tests: [
        CodeTestResult(name: '[2,7,11,15], target 9 → [0,1]', passed: true),
        CodeTestResult(name: '[3,2,4], target 6 → [1,2]', passed: true),
        CodeTestResult(name: '[3,3], target 6 → [0,1]', passed: false),
      ],
      runOutput: '''Result length: 0

✓ Program finished with exit code 0''',
      hint:
          'For each number, check whether target - num is already in a HashMap. '
          'If it is, you found the pair; if not, store the number and move on. '
          'One pass — O(n) time.',
    ),
    PracticeProblem(
      id: 'prob-palindrome',
      title: 'Palindrome Check',
      difficulty: 'Easy',
      language: 'Python',
      description:
          'Write a function that returns True if the given string reads the '
          'same forwards and backwards, and False otherwise. Ignore case and '
          'non-letter characters.',
      examples: [
        ProblemExample(
          input: 's = "madam"',
          output: 'True',
        ),
        ProblemExample(
          input: 's = "hello"',
          output: 'False',
        ),
      ],
      constraints: [
        '1 <= len(s) <= 1000',
        's contains letters, digits and spaces.',
      ],
      starterCode: '''def is_palindrome(s: str) -> bool:
    # TODO: return True if s reads the same forwards and backwards.
    return False


print(is_palindrome("madam"))   # expect True
print(is_palindrome("hello"))   # expect False
print(is_palindrome("level"))   # expect True
''',
      fileName: 'main.py',
      tests: [
        CodeTestResult(name: '"madam" → True', passed: true),
        CodeTestResult(name: '"hello" → False', passed: true),
        CodeTestResult(name: '"A man a plan" → True', passed: false),
      ],
      runOutput: '''False
False
False

✓ Program finished with exit code 0''',
      hint:
          'Clean the string first (lowercase, keep letters only), then compare '
          'it with its reverse: s == s[::-1].',
    ),
    PracticeProblem(
      id: 'prob-fizzbuzz',
      title: 'FizzBuzz',
      difficulty: 'Easy',
      language: 'JavaScript',
      description:
          'Write fizzBuzz(n): return "FizzBuzz" if n is divisible by both 3 '
          'and 5, "Fizz" if only by 3, "Buzz" if only by 5, otherwise the '
          'number itself as a string.',
      examples: [
        ProblemExample(
          input: 'n = 3',
          output: '"Fizz"',
        ),
        ProblemExample(
          input: 'n = 15',
          output: '"FizzBuzz"',
          explanation: '15 is divisible by both 3 and 5.',
        ),
      ],
      constraints: [
        '1 <= n <= 100',
      ],
      starterCode: '''function fizzBuzz(n) {
  // TODO: return "Fizz" for multiples of 3, "Buzz" for 5,
  // "FizzBuzz" for both, otherwise the number as a string.
  return "";
}

for (let i = 1; i <= 15; i++) {
  console.log(fizzBuzz(i));
}
''',
      fileName: 'fizzbuzz.js',
      tests: [
        CodeTestResult(name: 'fizzBuzz(3) → "Fizz"', passed: true),
        CodeTestResult(name: 'fizzBuzz(5) → "Buzz"', passed: true),
        CodeTestResult(name: 'fizzBuzz(15) → "FizzBuzz"', passed: false),
      ],
      runOutput: '''
















✓ Program finished with exit code 0''',
      hint:
          'Check the "both" case FIRST (n % 15 === 0) — if you check 3 first, '
          '15 returns "Fizz" and never reaches the combined case.',
    ),
    PracticeProblem(
      id: 'prob-reverse-string',
      title: 'Reverse String',
      difficulty: 'Easy',
      language: 'Python',
      description:
          'Write a function that returns the input string reversed. Try it '
          'without using slicing first, then compare with the one-line '
          'Python way.',
      examples: [
        ProblemExample(
          input: 's = "hello"',
          output: '"olleh"',
        ),
        ProblemExample(
          input: 's = "CodeShikhi"',
          output: '"ihkihSedoC"',
        ),
      ],
      constraints: [
        '1 <= len(s) <= 1000',
      ],
      starterCode: '''def reverse_string(s: str) -> str:
    # TODO: return s reversed.
    return s


print(reverse_string("hello"))       # expect "olleh"
print(reverse_string("CodeShikhi"))  # expect "ihkihSedoC"
''',
      fileName: 'main.py',
      tests: [
        CodeTestResult(name: '"hello" → "olleh"', passed: true),
        CodeTestResult(name: '"" → ""', passed: true),
        CodeTestResult(name: '"CodeShikhi" → "ihkihSedoC"', passed: false),
      ],
      runOutput: '''hello
CodeShikhi

✓ Program finished with exit code 0''',
      hint:
          'The Python one-liner is s[::-1]. For the manual version, build a '
          'new string by walking from the last character to the first.',
    ),
    PracticeProblem(
      id: 'prob-max-subarray',
      title: 'Maximum Subarray',
      difficulty: 'Medium',
      language: 'Java',
      description:
          'Given an integer array nums, find the contiguous subarray (with at '
          'least one number) that has the largest sum, and return its sum.',
      examples: [
        ProblemExample(
          input: 'nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]',
          output: '6',
          explanation: 'The subarray [4, -1, 2, 1] sums to 6.',
        ),
        ProblemExample(
          input: 'nums = [1]',
          output: '1',
        ),
      ],
      constraints: [
        '1 <= nums.length <= 10^5',
        '-10^4 <= nums[i] <= 10^4',
        'Try O(n) time and O(1) space.',
      ],
      starterCode: '''class Solution {
    // Return the largest sum of any contiguous subarray.
    public int maxSubArray(int[] nums) {
        // TODO: Kadane's algorithm — O(n) time, O(1) space.
        return 0;
    }

    public static void main(String[] args) {
        Solution s = new Solution();
        System.out.println(
            s.maxSubArray(new int[]{-2, 1, -3, 4, -1, 2, 1, -5, 4}));
    }
}
''',
      fileName: 'Solution.java',
      tests: [
        CodeTestResult(name: '[-2,1,-3,4,-1,2,1,-5,4] → 6', passed: true),
        CodeTestResult(name: '[1] → 1', passed: true),
        CodeTestResult(name: '[-1,-2,-3] → -1', passed: false),
      ],
      runOutput: '''0

✓ Program finished with exit code 0''',
      hint:
          'Kadane\'s algorithm: keep a running sum. At each number, either '
          'extend the current subarray or start fresh from this number — '
          'whichever is larger. Track the best sum seen so far.',
    ),
    PracticeProblem(
      id: 'prob-valid-parentheses',
      title: 'Valid Parentheses',
      difficulty: 'Medium',
      language: 'JavaScript',
      description:
          'Given a string s containing just the characters ( ) { } [ ], '
          'determine if the input string is valid. A string is valid when '
          'every open bracket is closed by the same type of bracket, in the '
          'correct order.',
      examples: [
        ProblemExample(
          input: 's = "()[]{}"',
          output: 'true',
        ),
        ProblemExample(
          input: 's = "(]"',
          output: 'false',
        ),
      ],
      constraints: [
        '1 <= s.length <= 10^4',
        's consists of brackets only.',
      ],
      starterCode: '''function isValid(s) {
  // TODO: return true if every bracket is closed in the right order.
  return false;
}

console.log(isValid("()"));       // true
console.log(isValid("()[]{}"));   // true
console.log(isValid("(]"));       // false
''',
      fileName: 'valid.js',
      tests: [
        CodeTestResult(name: 'isValid("()") → true', passed: true),
        CodeTestResult(name: 'isValid("()[]{}") → true', passed: true),
        CodeTestResult(name: 'isValid("(]") → false', passed: false),
      ],
      runOutput: '''false
false
false

✓ Program finished with exit code 0''',
      hint:
          'Use a stack: push every opening bracket, and on a closing bracket '
          'check the top of the stack matches. The string is valid only if '
          'the stack is empty at the end.',
    ),
  ];

  static PracticeProblem? byId(String id) {
    for (final p in problems) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Editor-ready project per problem id (starter file + canned output).
  /// The editor resolves these when the id is not a demo project.
  static Map<String, CodeProject> get problemProjects => {
        for (final p in problems)
          p.id: CodeProject(
            id: p.id,
            title: p.title,
            language: p.language,
            files: [ProjectFile(name: p.fileName, content: p.starterCode)],
            lastEdited: 'Practice problem',
            runOutput: p.runOutput,
            tests: p.tests,
          ),
      };
}
