#!/usr/bin/env python3
import json, sys, pathlib

def render(template_path: str, json_path: str, out_path: str):
    tpl = pathlib.Path(template_path).read_text(encoding="utf-8")
    ctx = json.loads(pathlib.Path(json_path).read_text(encoding="utf-8"))
    for k, v in ctx.items():
        tpl = tpl.replace("{{" + k + "}}", str(v))
    # Clean up any untouched placeholders:
    tpl = tpl.replace("{{tier_label}}", ctx.get("tier_label", ""))
    pathlib.Path(out_path).write_text(tpl, encoding="utf-8")
    print(f"Wrote {out_path}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: render_cert.py <template.html> <data.json> <out.html>")
        sys.exit(1)
    render(sys.argv[1], sys.argv[2], sys.argv[3])
