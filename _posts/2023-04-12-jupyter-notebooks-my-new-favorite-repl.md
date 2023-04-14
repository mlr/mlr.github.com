---
title: Jupyter Notebooks&colon; My New Favorite REPL
---

As a web developer, I've been familiar with Python for many years, particularly in the context of web development. However, recently, while exploring Python libraries and tools and learning about Language Models (LLMs) and Generative AI, I really came to appreciate the power of Jupyter Notebooks. Although I had seen them before I never really tried them. They have proven to be extremely helpful when trying to grasp new Python concepts.

## What are Jupyter Notebooks?

Jupyter Notebooks are an open-source web application that enables you to create and share documents containing live code, equations, visualizations, and narrative text. These notebooks support many programming languages, including Python, R, and Julia. With Jupyter Notebooks, you can create a shareable Python REPL (Read-Evaluate-Print Loop) in your browser.

## Why are Jupyter Notebooks Great?

Jupyter Notebooks have become a popular tool among data scientists and developers for several reasons:

* Portability: Jupyter Notebooks can be easily shared with others, making it an excellent tool for collaboration.
* Interactivity: Jupyter Notebooks allow you to write and execute code, see the output, and modify it all in one place.
* Versatility: Jupyter Notebooks can be used for data cleaning and transformation, numerical simulation, statistical modeling, data visualization, machine learning, and much more.
* Built-in UI components: Jupyter Notebooks have a built-in system for creating graphical user interfaces (GUIs), which allows developers to quickly create interactive components for their notebooks.
* Environment Management: Jupyter Notebooks allow you to use Dockerfiles to build your environment, making it easy to maintain consistency between environments.

## Additional History of Jupyter Notebooks

Jupyter Notebooks evolved from the IPython project, which was initiated by Fernando Pérez in 2001 [[source](https://en.wikipedia.org/wiki/Jupyter#History)]. IPython was a command shell for interactive computing that provided enhanced introspection, rich media, shell syntax, tab completion, and history. It was written in Python and intended to be a better alternative to the default Python shell.

In 2014, the IPython team released the first version of Jupyter Notebook as a web-based interactive computational environment. It was named Jupyter after the three programming languages that it initially supported: Julia, Python, and R.

Since then, Jupyter Notebook has grown in popularity, and its user base now includes data scientists, researchers, educators, and developers.

## An Example of Jupyter Notebooks

Let's take a look at an example of how Jupyter Notebooks can be used in the context of LLMs and Generative AI. The following is a Jupyter Notebook containing Python code that uses OpenAI's GPT-3 to generate a description of a person and their age at death multiplied by 3.

<figcaption>AgentNotebook.ipynb</figcaption>

```python
%load_ext dotenv
%dotenv

from langchain.agents import load_tools
from langchain.agents import initialize_agent
from langchain.agents import AgentType
from langchain.chat_models import ChatOpenAI
from langchain.llms import OpenAI

# First, let's load the language model we're going to use to control the agent.
chat = ChatOpenAI(temperature=0)

# Next, let's load some tools to use.
# Note that the `llm-math` tool uses an LLM, so we need to pass that in.
llm = OpenAI(temperature=0, max_tokens=2048)
tools = load_tools(["llm-math", "wikipedia"], llm=llm)

# Initialize an agent with tools, the LLM, and the type of agent we want.
agent = initialize_agent(tools, chat,
                          verbose=True,
                          agent=AgentType.CHAT_ZERO_SHOT_REACT_DESCRIPTION)

# Now let's test it out!
agent.run("Who was Ada Lovelace? What is her age at death times 3?")
```

## Conclusion

In summary, Jupyter Notebooks are an incredibly versatile tool that can be used for a wide range of tasks. Whether you’re a data scientist or a developer, Jupyter Notebooks can help you streamline your workflow and shorten your feedback loop when learning new Python concepts.

## Resources

- [Official Jupyter Notebook documentation](https://jupyter-notebook.readthedocs.io/en/stable/)
- [Jupyter Notebook tutorials on DataCamp](https://www.datacamp.com/community/tutorials/tutorial-jupyter-notebook)
- [Jupyter Notebook extension gallery](https://jupyter-contrib-nbextensions.readthedocs.io/en/latest/)
- [Jupyter Notebook cheat sheet](https://www.edureka.co/blog/wp-content/uploads/2018/10/Jupyter_Notebook_CheatSheet_Edureka.pdf)
- [Jupyter Notebook examples on GitHub](https://github.com/jupyter/jupyter/wiki#a-gallery-of-interesting-jupyter-notebooks)
