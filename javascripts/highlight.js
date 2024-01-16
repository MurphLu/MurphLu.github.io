document$.subscribe(() => {
    hljs.highlightAll();
    hljs.initLineNumbersOnLoad();
})