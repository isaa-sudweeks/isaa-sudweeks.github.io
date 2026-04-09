# isaacsudweeks.github.io

Minimal GitHub Pages setup for publishing research notes from Markdown.

## Structure

```text
_posts/        Published posts
_drafts/       In-progress notes
assets/images/ Figures and screenshots
templates/     Writing templates
scripts/       Small workflow helpers
```

## Workflow

1. Read and take notes in Zotero and Obsidian.
2. Refine the note until it is close to a public writeup.
3. Copy or publish the note into this repo.
4. Commit and push to `main`.
5. GitHub Pages rebuilds the site automatically.

## Local preview

If you want to preview locally:

```bash
bundle install
bundle exec jekyll serve
```

Then open `http://127.0.0.1:4000`.

## Fast publish helper

If your Obsidian note does not already include Jekyll frontmatter:

```bash
scripts/publish_note.sh /absolute/path/to/note.md
```

Optional explicit date:

```bash
scripts/publish_note.sh /absolute/path/to/note.md 2026-04-08
```

If the source file already contains frontmatter, the script copies it directly into `_posts/`.

## Writing template

Use:

- `templates/research-note-template.md` for raw note-taking
- `_drafts/in-progress-paper.md` for an in-repo draft post

## First GitHub setup

In the repo settings on GitHub:

1. Open `Settings` -> `Pages`
2. Set `Source` to `GitHub Actions`

For a user site named `isaacsudweeks.github.io`, the published URL will be:

`https://isaacsudweeks.github.io`
