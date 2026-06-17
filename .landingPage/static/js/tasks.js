document.addEventListener('DOMContentLoaded', () => {
  // No persistence: interactive checkboxes without localStorage (by request)

  // Helper to normalize text node trimming
  function trimStartText(node) {
    return node.textContent.replace(/^\s*\[[ xX]?\]\s*/, '');
  }

  // Find list items that look like Markdown task items ([ ] or [x])
  const lists = Array.from(document.querySelectorAll('main ul, main ol'));
  lists.forEach((list, listIdx) => {
    const items = Array.from(list.querySelectorAll('li'));
    let hasTasks = false;
    let taskCounter = 0;

    // toolbar (mark all / clear)
    const toolbar = document.createElement('div');
    toolbar.className = 'task-toolbar';
    const btnMarkAll = document.createElement('button');
    btnMarkAll.type = 'button';
    btnMarkAll.textContent = 'Marcar tudo';
    const btnClear = document.createElement('button');
    btnClear.type = 'button';
    btnClear.textContent = 'Limpar';
    toolbar.appendChild(btnMarkAll);
    toolbar.appendChild(btnClear);

    items.forEach((li) => {
      const txt = li.textContent || '';
      const m = txt.match(/^\s*\[([ xX])\]\s+/);
      if (m) {
        hasTasks = true;
        taskCounter += 1;
        const checked = (m[1].toLowerCase() === 'x');

        const originalHTML = li.innerHTML;
        let contentHTML = originalHTML.replace(/^\s*\[[ xX]?\]\s*/, '');

        // attempt to strip leading numeric emoji (e.g. "1️⃣ ") and other emoji clusters
        try {
          contentHTML = contentHTML.replace(/^\s*(?:\d+[\uFE0F\u20E3]*|[\p{Emoji}\uFE0F\u20E3]+)\s*/u, '');
        } catch (err) {
          // fallback for older engines: remove leading digits and common symbol characters
          contentHTML = contentHTML.replace(/^\s*[\d#*\-\u20E3\uFE0F]+\s*/, '');
        }

        const isChecked = !!checked;

        li.innerHTML = '';

        const input = document.createElement('input');
        input.type = 'checkbox';
        input.className = 'task-toggle';
        input.checked = !!isChecked;

        const number = document.createElement('span');
        number.className = 'task-number';
        number.textContent = String(taskCounter) + '.';

        const content = document.createElement('div');
        content.className = 'task-content';
        content.innerHTML = contentHTML;

        li.appendChild(input);
        li.appendChild(number);
        li.appendChild(content);

        if (input.checked) li.classList.add('task-done');

        input.addEventListener('change', () => {
          li.classList.toggle('task-done', input.checked);
        });
      }
    });

    if (hasTasks) {
      list.classList.add('task-list');
      // insert toolbar before the list
      list.parentNode.insertBefore(toolbar, list);

      // button handlers
      btnMarkAll.addEventListener('click', () => {
        const inputs = list.querySelectorAll('input.task-toggle');
        inputs.forEach((input, idx) => {
          if (!input.checked) {
            input.checked = true;
            input.dispatchEvent(new Event('change'));
          }
        });
      });

      btnClear.addEventListener('click', () => {
        const inputs = list.querySelectorAll('input.task-toggle');
        inputs.forEach((input) => {
          if (input.checked) {
            input.checked = false;
            input.dispatchEvent(new Event('change'));
          }
        });
      });
    }
  });
});
