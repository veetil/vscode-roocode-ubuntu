# RooCode Modular System Examples

This document provides detailed examples of how to use the RooCode Modular System for various scenarios.

## Basic Examples

### Creating a Simple Experiment

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment"
```

This command creates a new experiment folder named `calculator_experiment` in `/home/ubuntu/LaunchRoo/evals/python/` and saves the question to `question.md` in that folder.

### Creating an Experiment with a Prompt

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --prompt "Create a calculator with add, subtract, multiply, and divide functions."
```

This command creates a new experiment folder, saves the question to `question.md`, and saves the prompt to `outline.md` in that folder.

### Creating an Experiment with Files

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --files "calculator.py:calculator.py,test_calculator.py:test_calculator.py"
```

This command creates a new experiment folder, saves the question to `question.md`, and copies `calculator.py` and `test_calculator.py` to the experiment folder.

### Creating an Experiment with Output Files

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --files "calculator.py:calculator.py,test_calculator.py:test_calculator.py" \
  --output "calculator.py,test_calculator.py"
```

This command creates a new experiment folder, saves the question to `question.md`, copies `calculator.py` and `test_calculator.py` to the experiment folder, and copies those files to the output directory.

### Creating an Experiment with All Output Files

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --files "calculator.py:calculator.py,test_calculator.py:test_calculator.py" \
  --output-all
```

This command creates a new experiment folder, saves the question to `question.md`, copies `calculator.py` and `test_calculator.py` to the experiment folder, and copies all files in the experiment folder to the output directory.

## Advanced Examples

### Creating an Experiment with Nested Files

```bash
./roocode-modular.sh \
  --question "How do I implement a web application in Python?" \
  --expt "web_app_experiment" \
  --files "app.py:app.py,templates/index.html:templates/index.html,static/style.css:static/style.css"
```

This command creates a new experiment folder, saves the question to `question.md`, and copies `app.py`, `templates/index.html`, and `static/style.css` to the experiment folder, creating the necessary subdirectories.

### Creating an Experiment with a Complex Prompt

```bash
./roocode-modular.sh \
  --question "How do I implement a web application in Python?" \
  --expt "web_app_experiment" \
  --prompt "Create a web application with the following features:
1. User authentication
2. Database integration
3. RESTful API
4. Frontend using HTML, CSS, and JavaScript"
```

This command creates a new experiment folder, saves the question to `question.md`, and saves the multi-line prompt to `outline.md` in that folder.

### Creating an Experiment with Multiple Files and Specific Output

```bash
./roocode-modular.sh \
  --question "How do I implement a web application in Python?" \
  --expt "web_app_experiment" \
  --files "app.py:app.py,templates/index.html:templates/index.html,static/style.css:static/style.css,requirements.txt:requirements.txt" \
  --output "app.py,requirements.txt"
```

This command creates a new experiment folder, saves the question to `question.md`, copies all specified files to the experiment folder, and copies only `app.py` and `requirements.txt` to the output directory.

### Creating an Experiment with a Different Source and Destination

```bash
./roocode-modular.sh \
  --question "How do I implement a calculator in Python?" \
  --expt "calculator_experiment" \
  --files "/path/to/source/calculator.py:calculator_renamed.py"
```

This command creates a new experiment folder, saves the question to `question.md`, and copies `/path/to/source/calculator.py` to `/home/ubuntu/LaunchRoo/evals/python/calculator_experiment/calculator_renamed.py`.

### Creating an Experiment with a Prompt from a File

```bash
./roocode-modular.sh \
  --question "How do I implement a web application in Python?" \
  --expt "web_app_experiment" \
  --prompt "$(cat prompt.txt)"
```

This command creates a new experiment folder, saves the question to `question.md`, and saves the content of `prompt.txt` to `outline.md` in that folder.

## Real-World Scenarios

### Scenario 1: Simple Python Script

**Task**: Create a simple Python script that calculates the factorial of a number.

```bash
# Create the factorial.py file
cat > factorial.py << 'EOF'
def factorial(n):
    if n == 0 or n == 1:
        return 1
    else:
        return n * factorial(n-1)

if __name__ == "__main__":
    num = int(input("Enter a number: "))
    print(f"The factorial of {num} is {factorial(num)}")
EOF

# Create the test_factorial.py file
cat > test_factorial.py << 'EOF'
import unittest
from factorial import factorial

class TestFactorial(unittest.TestCase):
    def test_factorial_of_0(self):
        self.assertEqual(factorial(0), 1)
        
    def test_factorial_of_1(self):
        self.assertEqual(factorial(1), 1)
        
    def test_factorial_of_5(self):
        self.assertEqual(factorial(5), 120)
        
if __name__ == "__main__":
    unittest.main()
EOF

# Run the RooCode Modular System
./roocode-modular.sh \
  --question "How do I calculate the factorial of a number in Python?" \
  --expt "factorial_experiment" \
  --files "factorial.py:factorial.py,test_factorial.py:test_factorial.py" \
  --prompt "Create a Python function to calculate the factorial of a number. Include error handling and tests." \
  --output-all
```

### Scenario 2: Web Application

**Task**: Create a simple Flask web application.

```bash
# Create the app.py file
cat > app.py << 'EOF'
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
EOF

# Create the templates directory and index.html file
mkdir -p templates
cat > templates/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Flask App</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <h1>Hello, Flask!</h1>
</body>
</html>
EOF

# Create the static directory and style.css file
mkdir -p static
cat > static/style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
    background-color: #f0f0f0;
}

h1 {
    color: #333;
}
EOF

# Create the requirements.txt file
cat > requirements.txt << 'EOF'
Flask==2.0.1
EOF

# Run the RooCode Modular System
./roocode-modular.sh \
  --question "How do I create a simple Flask web application?" \
  --expt "flask_experiment" \
  --files "app.py:app.py,templates/index.html:templates/index.html,static/style.css:static/style.css,requirements.txt:requirements.txt" \
  --prompt "Create a simple Flask web application with a home page. Include proper directory structure and styling." \
  --output-all
```

### Scenario 3: Data Analysis

**Task**: Create a Python script for data analysis.

```bash
# Create the data_analysis.py file
cat > data_analysis.py << 'EOF'
import pandas as pd
import matplotlib.pyplot as plt

def load_data(file_path):
    return pd.read_csv(file_path)

def analyze_data(data):
    # Calculate basic statistics
    stats = data.describe()
    
    # Create a histogram
    plt.figure(figsize=(10, 6))
    data.hist()
    plt.tight_layout()
    plt.savefig('histogram.png')
    
    return stats

if __name__ == "__main__":
    data = load_data('data.csv')
    stats = analyze_data(data)
    print(stats)
EOF

# Create the data.csv file
cat > data.csv << 'EOF'
id,value
1,10
2,15
3,20
4,25
5,30
EOF

# Create the requirements.txt file
cat > requirements.txt << 'EOF'
pandas==1.3.3
matplotlib==3.4.3
EOF

# Run the RooCode Modular System
./roocode-modular.sh \
  --question "How do I perform data analysis in Python?" \
  --expt "data_analysis_experiment" \
  --files "data_analysis.py:data_analysis.py,data.csv:data.csv,requirements.txt:requirements.txt" \
  --prompt "Create a Python script for data analysis. Include functions for loading data, calculating statistics, and creating visualizations." \
  --output "data_analysis.py,requirements.txt"
```

## Conclusion

These examples demonstrate the flexibility and power of the RooCode Modular System. You can use it for a wide range of scenarios, from simple scripts to complex applications.

For more information, refer to the [User Guide](USER_GUIDE.md) and [Developer Guide](DEVELOPER_GUIDE.md).