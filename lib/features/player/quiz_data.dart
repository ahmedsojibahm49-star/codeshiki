/// Quiz question banks for the demo app — one bank of 10 real multiple
/// choice questions per course. Every lesson quiz in a course draws from
/// that course's bank.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options; // exactly 4
  final int correctIndex;
  final String explanation;
}

/// Question banks keyed by courseId.
const Map<String, List<QuizQuestion>> quizBanks = {
  'react-js-zero': [
    QuizQuestion(
      question: 'Which hook is used to manage state in a function component?',
      options: ['useEffect', 'useState', 'useMemo', 'useRef'],
      correctIndex: 1,
      explanation:
          'useState returns a state value and a setter function. Calling the setter re-renders the component with the new value.',
    ),
    QuizQuestion(
      question: 'What does JSX compile down to?',
      options: [
        'HTML strings',
        'React.createElement() calls',
        'CSS modules',
        'Web Components',
      ],
      correctIndex: 1,
      explanation:
          'JSX is syntactic sugar — Babel turns <h1>Hello</h1> into React.createElement("h1", null, "Hello").',
    ),
    QuizQuestion(
      question: 'How should a component treat its props?',
      options: [
        'Props are mutable and can be changed freely',
        'Props can be changed only inside useEffect',
        'Props are read-only — never modify them directly',
        'Props are only for class components',
      ],
      correctIndex: 2,
      explanation:
          'Props flow one way, parent to child, and are read-only. To change data, the parent updates its own state and passes new props down.',
    ),
    QuizQuestion(
      question: 'When does useEffect run by default?',
      options: [
        'Before the component renders',
        'Only once, when the app starts',
        'After every render, unless a dependency array limits it',
        'Only when the user clicks something',
      ],
      correctIndex: 2,
      explanation:
          'useEffect runs after render. With no dependency array it runs after every render; with [] it runs once; with [a, b] it runs when a or b changes.',
    ),
    QuizQuestion(
      question: 'Why do list items in React need a unique "key" prop?',
      options: [
        'To style each item differently',
        'So React can identify which items changed, moved, or were removed',
        'To make the list searchable',
        'Keys are required by JavaScript itself',
      ],
      correctIndex: 1,
      explanation:
          'Keys help React match old and new list items during reconciliation, so it updates only what actually changed instead of rebuilding the whole list.',
    ),
    QuizQuestion(
      question: 'What happens when you call a state setter from useState?',
      options: [
        'The value changes immediately, synchronously',
        'React schedules a re-render with the new value',
        'The component unmounts',
        'The page reloads',
      ],
      correctIndex: 1,
      explanation:
          'State updates are scheduled, not instant. React batches them and re-renders the component with the new state.',
    ),
    QuizQuestion(
      question: 'Which hook is the right place for fetching data from an API?',
      options: ['useState', 'useRef', 'useEffect', 'useMemo'],
      correctIndex: 2,
      explanation:
          'Data fetching is a side effect, so it belongs in useEffect — typically with an empty dependency array so it runs once after mount.',
    ),
    QuizQuestion(
      question: 'What must a component return?',
      options: [
        'Always a <div> element',
        'A single root JSX element (or a fragment, string, or null)',
        'An array of strings',
        'A class instance',
      ],
      correctIndex: 1,
      explanation:
          'A component returns one root node. Use a fragment <>...</> when you need siblings without an extra wrapper element.',
    ),
    QuizQuestion(
      question: 'What does useRef return?',
      options: [
        'A state value that triggers re-renders',
        'A mutable ref object whose .current persists across renders',
        'A memoized callback function',
        'The DOM node of the parent',
      ],
      correctIndex: 1,
      explanation:
          'useRef returns { current: initialValue }. Changing .current does NOT trigger a re-render, which makes it ideal for timers, DOM access, and holding values.',
    ),
    QuizQuestion(
      question: 'What is the Virtual DOM?',
      options: [
        'A real browser DOM running in a web worker',
        'A lightweight in-memory copy of the UI that React diffs to update only what changed',
        'A database that stores component state',
        'A CSS engine for React Native',
      ],
      correctIndex: 1,
      explanation:
          'React keeps a lightweight tree in memory, compares it with the previous tree after each render, and applies only the minimal set of real DOM changes.',
    ),
  ],
  'python-one-night': [
    QuizQuestion(
      question: 'Which of these is a valid Python variable name?',
      options: ['2name', 'my-name', '_total', 'class'],
      correctIndex: 2,
      explanation:
          'Names must start with a letter or underscore and contain only letters, digits, and underscores. "class" is a reserved keyword.',
    ),
    QuizQuestion(
      question: 'What does len("CodeShikhi") return?',
      options: ['9', '10', '11', 'An error — len only works on lists'],
      correctIndex: 1,
      explanation:
          'len() counts characters in a string. "CodeShikhi" has 10 letters, and len() works on strings, lists, dicts, and more.',
    ),
    QuizQuestion(
      question: 'Which statement about Python lists is true?',
      options: [
        'Lists are immutable — you cannot change them',
        'Lists can only hold numbers',
        'Lists are mutable and can hold mixed types',
        'Lists are unordered',
      ],
      correctIndex: 2,
      explanation:
          'Lists are ordered, mutable sequences. A single list can hold ints, strings, and even other lists together.',
    ),
    QuizQuestion(
      question: 'How does Python mark a block of code, like the body of an if?',
      options: [
        'Curly braces { }',
        'Indentation',
        'The begin/end keywords',
        'Semicolons',
      ],
      correctIndex: 1,
      explanation:
          'Python uses indentation (usually 4 spaces) to define blocks. Consistent indentation is not just style — it is syntax.',
    ),
    QuizQuestion(
      question: 'Which keyword defines a function in Python?',
      options: ['func', 'function', 'def', 'define'],
      correctIndex: 2,
      explanation:
          'Functions are defined with def, e.g. def greet(name): — followed by an indented body.',
    ),
    QuizQuestion(
      question: 'What does range(3) produce in a for loop?',
      options: [
        '1, 2, 3',
        '0, 1, 2',
        '0, 1, 2, 3',
        '3, 2, 1',
      ],
      correctIndex: 1,
      explanation:
          'range(3) produces 0, 1, 2 — it starts at 0 and stops BEFORE 3. range(n) always gives n values starting from 0.',
    ),
    QuizQuestion(
      question: 'What does a Python dict store?',
      options: [
        'Only unique values, in order',
        'Key-value pairs, looked up by key',
        'Fixed-size arrays of numbers',
        'Only string keys and string values',
      ],
      correctIndex: 1,
      explanation:
          'A dict maps keys to values, like {"name": "Rahim"}. Lookup by key is fast, and keys can be strings, numbers, tuples, and more.',
    ),
    QuizQuestion(
      question: 'What does `if __name__ == "__main__":` do?',
      options: [
        'It imports the main module',
        'It runs the block only when the file is executed directly, not when imported',
        'It defines the main function',
        'It checks the file name on disk',
      ],
      correctIndex: 1,
      explanation:
          'When a file runs directly, Python sets __name__ to "__main__". When imported, __name__ is the module name — so the guarded code is skipped.',
    ),
    QuizQuestion(
      question: 'What does the // operator do in Python?',
      options: [
        'Divides and returns the remainder',
        'Divides and rounds the result down to the nearest integer',
        'Comments out the rest of the line',
        'Divides and returns a float',
      ],
      correctIndex: 1,
      explanation:
          '// is floor division: 7 // 2 is 3. The remainder operator is % — 7 % 2 is 1.',
    ),
    QuizQuestion(
      question: 'Which method adds an item to the END of a list?',
      options: ['add()', 'push()', 'append()', 'insert()'],
      correctIndex: 2,
      explanation:
          'append() adds one item to the end: nums.append(5). insert(i, x) adds at a specific index instead.',
    ),
  ],
  'mern-project-camp': [
    QuizQuestion(
      question: 'What does the "M" in MERN stand for?',
      options: ['MySQL', 'MongoDB', 'Mongoose', 'Middleware'],
      correctIndex: 1,
      explanation:
          'MERN = MongoDB, Express, React, Node.js — a full JavaScript stack from database to UI.',
    ),
    QuizQuestion(
      question: 'What is Express?',
      options: [
        'A database for Node.js',
        'A minimal web framework for building APIs and servers in Node.js',
        'A React state library',
        'A testing tool',
      ],
      correctIndex: 1,
      explanation:
          'Express is a fast, minimal framework on top of Node.js http — routing, middleware, and request handling with very little boilerplate.',
    ),
    QuizQuestion(
      question: 'In a REST API, what is a GET request used for?',
      options: [
        'Creating a new resource',
        'Updating a resource',
        'Retrieving data without changing anything',
        'Deleting a resource',
      ],
      correctIndex: 2,
      explanation:
          'GET retrieves data and should have no side effects. POST creates, PUT/PATCH updates, DELETE removes.',
    ),
    QuizQuestion(
      question: 'What is a JWT (JSON Web Token) mainly used for?',
      options: [
        'Styling web pages',
        'Authentication — proving a client is logged in',
        'Compressing images',
        'Connecting to MongoDB',
      ],
      correctIndex: 1,
      explanation:
          'After login, the server signs a JWT. The client sends it with each request, and the server verifies the signature instead of keeping sessions.',
    ),
    QuizQuestion(
      question: 'How does MongoDB store data?',
      options: [
        'In tables with rows and columns',
        'As JSON-like documents grouped in collections',
        'In plain text files only',
        'As key-value pairs in memory only',
      ],
      correctIndex: 1,
      explanation:
          'MongoDB is a document database: flexible JSON-like documents (stored as BSON) grouped into collections — no fixed schema required.',
    ),
    QuizQuestion(
      question: 'Which HTTP status code means "Created" after a successful POST?',
      options: ['200', '201', '301', '404'],
      correctIndex: 1,
      explanation:
          '201 Created is the correct response when a POST creates a new resource. 200 means generic success; 404 means not found.',
    ),
    QuizQuestion(
      question: 'What is Mongoose?',
      options: [
        'A React router',
        'An ODM (Object Data Modeling) library that adds schemas and validation to MongoDB in Node.js',
        'A Node.js package manager',
        'A CSS framework',
      ],
      correctIndex: 1,
      explanation:
          'Mongoose lets you define schemas and models for MongoDB documents, with validation, middleware, and typed queries.',
    ),
    QuizQuestion(
      question: 'What does CORS control?',
      options: [
        'Database connection pooling',
        'Whether a web page from one origin may call an API on another origin',
        'How fast Express serves static files',
        'Password hashing strength',
      ],
      correctIndex: 1,
      explanation:
          'Browsers block cross-origin requests by default. The server uses CORS headers to allow specific origins — e.g. your React app calling your API.',
    ),
    QuizQuestion(
      question: 'What does `npm start` do?',
      options: [
        'Installs all dependencies',
        'Runs the "start" script defined in package.json',
        'Starts MongoDB',
        'Publishes the package to npm',
      ],
      correctIndex: 1,
      explanation:
          'npm start runs the script named "start" in package.json — usually something like "node server.js".',
    ),
    QuizQuestion(
      question: 'What is Express middleware?',
      options: [
        'A function that runs between receiving a request and sending a response',
        'A database migration tool',
        'The HTML template engine',
        'A type of React component',
      ],
      correctIndex: 0,
      explanation:
          'Middleware functions receive (req, res, next) and can log, authenticate, parse bodies, or end the request — then call next() to continue the chain.',
    ),
  ],
  'dsa-java': [
    QuizQuestion(
      question: 'What is the time complexity of binary search on a sorted array?',
      options: ['O(1)', 'O(n)', 'O(log n)', 'O(n log n)'],
      correctIndex: 2,
      explanation:
          'Binary search halves the search space each step, so it takes about log2(n) comparisons — O(log n).',
    ),
    QuizQuestion(
      question: 'A stack follows which order?',
      options: ['FIFO — first in, first out', 'LIFO — last in, first out', 'Random access', 'Sorted order'],
      correctIndex: 1,
      explanation:
          'A stack is LIFO: push adds to the top, pop removes from the top — like a stack of plates.',
    ),
    QuizQuestion(
      question: 'A queue follows which order?',
      options: ['LIFO — last in, first out', 'FIFO — first in, first out', 'LILO — last in, last out', 'Sorted order'],
      correctIndex: 1,
      explanation:
          'A queue is FIFO: items leave in the order they arrived — like people waiting in line.',
    ),
    QuizQuestion(
      question: 'What is the time complexity of accessing an array element by index?',
      options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
      correctIndex: 0,
      explanation:
          'Arrays store elements in contiguous memory, so arr[i] is computed directly from the base address — constant time, O(1).',
    ),
    QuizQuestion(
      question: 'What is the average time complexity of a HashMap lookup?',
      options: ['O(n)', 'O(log n)', 'O(1)', 'O(n log n)'],
      correctIndex: 2,
      explanation:
          'A good hash function spreads keys evenly, so lookups average O(1). In the worst case (many collisions) it degrades toward O(n).',
    ),
    QuizQuestion(
      question: 'Breadth-first search (BFS) on a graph uses which data structure?',
      options: ['Stack', 'Queue', 'HashMap', 'Heap'],
      correctIndex: 1,
      explanation:
          'BFS explores level by level, visiting nodes in the order they were discovered — exactly what a queue provides.',
    ),
    QuizQuestion(
      question: 'Depth-first search (DFS) is most naturally implemented with…',
      options: ['A queue', 'Recursion (or an explicit stack)', 'A hash set only', 'Binary search'],
      correctIndex: 1,
      explanation:
          'DFS goes deep first: recursion uses the call stack to remember where to backtrack to, which matches DFS order exactly.',
    ),
    QuizQuestion(
      question: 'How many children can a node in a binary tree have at most?',
      options: ['1', '2', '3', 'Unlimited'],
      correctIndex: 1,
      explanation:
          'Binary means two: each node has at most a left child and a right child.',
    ),
    QuizQuestion(
      question: 'What is the lower bound for comparison-based sorting?',
      options: ['O(n)', 'O(log n)', 'O(n log n)', 'O(n²)'],
      correctIndex: 2,
      explanation:
          'Any sort that only compares elements needs at least O(n log n) comparisons in the worst case. Merge sort and heap sort achieve it.',
    ),
    QuizQuestion(
      question: 'What is the time complexity of inserting at the HEAD of a singly linked list?',
      options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
      correctIndex: 0,
      explanation:
          'Inserting at the head only rewires two pointers — the new node points at the old head, and head moves. No traversal needed: O(1).',
    ),
  ],
};

/// The quiz bank for a course. Unknown course ids fall back to the
/// React bank so a quiz always has 10 questions.
List<QuizQuestion> quizForLesson(String courseId) =>
    quizBanks[courseId] ?? quizBanks['react-js-zero']!;
