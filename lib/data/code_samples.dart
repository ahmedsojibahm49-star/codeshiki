import 'models.dart';

/// Demo code projects with real starter file contents, a canned run output
/// and pass/fail test rows. The editor is a demo: "Run" shows [runOutput],
/// it does not execute code.
class CodeSamples {
  CodeSamples._();

  static const List<CodeProject> projects = [
    CodeProject(
      id: 'counter-app',
      title: 'Counter App',
      language: 'React',
      lastEdited: 'Edited 2h ago',
      files: [
        ProjectFile(
          name: 'App.jsx',
          content: '''import { useState } from 'react';
import './styles.css';

export default function App() {
  const [count, setCount] = useState(0);

  return (
    <main className="card">
      <h1>Counter App</h1>
      <p className="count">{count}</p>
      <div className="row">
        <button onClick={() => setCount(count - 1)}>-</button>
        <button onClick={() => setCount(0)}>Reset</button>
        <button onClick={() => setCount(count + 1)}>+</button>
      </div>
    </main>
  );
}
''',
        ),
        ProjectFile(
          name: 'styles.css',
          content: '''.card {
  max-width: 320px;
  margin: 48px auto;
  padding: 24px;
  border-radius: 20px;
  background: #fff7f0;
  text-align: center;
  font-family: system-ui, sans-serif;
}

.count {
  font-size: 64px;
  font-weight: 800;
  color: #f97316;
}

.row {
  display: flex;
  gap: 12px;
  justify-content: center;
}

button {
  padding: 10px 18px;
  border: 0;
  border-radius: 12px;
  background: #f97316;
  color: #1c1917;
  font-weight: 600;
  cursor: pointer;
}
''',
        ),
        ProjectFile(
          name: 'index.js',
          content: '''import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

createRoot(document.getElementById('root'))
  .render(<App />);
''',
        ),
      ],
      runOutput: '''✓ Build passed in 1.2s
✓ App rendered — Counter shows 0
Tap + to count up, Reset to go back to 0.''',
      tests: [
        CodeTestResult(name: 'renders initial count 0', passed: true),
        CodeTestResult(name: 'increments on + tap', passed: true),
        CodeTestResult(name: 'decrements on - tap', passed: true),
        CodeTestResult(name: 'resets to 0', passed: true),
      ],
    ),
    CodeProject(
      id: 'hello-python',
      title: 'Hello Python',
      language: 'Python',
      lastEdited: 'Edited yesterday',
      files: [
        ProjectFile(
          name: 'main.py',
          content: '''def greet(name: str) -> str:
    return f"Hello, {name}! Welcome to CodeShikhi."


def main():
    names = ["Rahim", "Nusrat", "Tanvir"]
    for name in names:
        print(greet(name))

    total = sum(range(1, 11))
    print(f"Sum of 1..10 is {total}")


if __name__ == "__main__":
    main()
''',
        ),
      ],
      runOutput: '''Hello, Rahim! Welcome to CodeShikhi.
Hello, Nusrat! Welcome to CodeShikhi.
Hello, Tanvir! Welcome to CodeShikhi.
Sum of 1..10 is 55

✓ Program finished with exit code 0''',
      tests: [
        CodeTestResult(name: 'greet returns greeting', passed: true),
        CodeTestResult(name: 'prints 3 greetings', passed: true),
        CodeTestResult(name: 'sum of 1..10 is 55', passed: true),
      ],
    ),
    CodeProject(
      id: 'two-sum',
      title: 'Two Sum',
      language: 'Java',
      lastEdited: 'Edited 3 days ago',
      files: [
        ProjectFile(
          name: 'Solution.java',
          content: '''import java.util.HashMap;
import java.util.Map;

class Solution {
    // Return indices of the two numbers that add up to target.
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> seen = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int need = target - nums[i];
            if (seen.containsKey(need)) {
                return new int[]{seen.get(need), i};
            }
            seen.put(nums[i], i);
        }
        return new int[]{};
    }

    public static void main(String[] args) {
        Solution s = new Solution();
        int[] result = s.twoSum(new int[]{2, 7, 11, 15}, 9);
        System.out.println("[" + result[0] + ", " + result[1] + "]");
    }
}
''',
        ),
      ],
      runOutput: '''[0, 1]

✓ Program finished with exit code 0''',
      tests: [
        CodeTestResult(name: '[2,7,11,15], target 9 → [0,1]', passed: true),
        CodeTestResult(name: '[3,2,4], target 6 → [1,2]', passed: true),
        CodeTestResult(name: '[3,3], target 6 → [0,1]', passed: true),
        CodeTestResult(name: 'no pair returns empty', passed: false),
      ],
    ),
  ];

  static CodeProject? byId(String id) {
    for (final p in projects) {
      if (p.id == id) return p;
    }
    return null;
  }
}
