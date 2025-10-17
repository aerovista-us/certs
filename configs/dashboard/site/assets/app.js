
function setTab(id){
  for(const el of document.querySelectorAll('.tab')) el.classList.toggle('active', el.dataset.tab===id);
  for(const el of document.querySelectorAll('.panel')) el.classList.toggle('hidden', el.id!==id);
}

async function loadMarkdown(url, targetId){
  const res = await fetch(url);
  const text = await res.text();
  // Minimal markdown render: show as pre if no renderer available
  // (You can swap in a client-side renderer later; for now we keep it simple.)
  const target = document.getElementById(targetId);
  target.textContent = text;
}

function copyText(id){
  const el = document.getElementById(id);
  const text = el.innerText || el.textContent;
  navigator.clipboard.writeText(text).then(()=>{
    const btn = document.querySelector(`[data-copy='${id}']`);
    if(btn){ btn.innerText='Copied!'; setTimeout(()=>btn.innerText='Copy',1200); }
  });
}

window.addEventListener('DOMContentLoaded', () => {
  setTab('brief');
  loadMarkdown('./docs/postgresql_sop.md','postgres_md');
});
