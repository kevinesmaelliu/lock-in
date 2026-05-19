# Progress Bar

A lightweight macOS menu bar app that shows a tiny progress bar for how many of today’s tasks you’ve completed.

## Features

- **Menu bar indicator** — a small capsule bar that fills as you complete tasks (hover for `3/5 done (60%)`)
- **Popover panel** — add tasks, check them off, swipe to delete, clear completed
- **Daily reset** — tasks are scoped to the calendar day; a new day starts with a fresh list
- **No Dock icon** — lives only in the menu bar

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+ (to build and run)

## Run

1. Open `ProgressBar.xcodeproj` in Xcode.
2. Select the **ProgressBar** scheme and your Mac as the run destination.
3. Press **⌘R** to build and run.
4. Look for the progress bar in the menu bar (top right). Click it to manage tasks.

On first run, Xcode may ask you to set a **Development Team** under Signing & Capabilities for code signing.

## Project structure

```
ProgressBar/
  ProgressBarApp.swift      # MenuBarExtra entry point
  Models/
    DailyTask.swift         # Task model
    TaskStore.swift         # Persistence + progress math
  Views/
    MenuBarProgressView.swift   # Tiny menu bar bar
    MenuContentView.swift       # Popover UI
    TaskRowView.swift
```

Tasks are stored in `UserDefaults` under `com.progressbar.daily.tasks`.

## Ideas for later

- Sync with Reminders, Things, or Todoist
- Carry incomplete tasks to the next day
- Keyboard shortcut to add a task
- Menu bar label with fraction (`2/5`)
