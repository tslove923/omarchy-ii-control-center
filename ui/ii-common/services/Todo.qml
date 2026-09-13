pragma Singleton
pragma ComponentBehavior: Bound
import "../stubs"
import Quickshell
import Quickshell.Io
import QtQuick

// Vendored verbatim from ii's services/Todo.qml -- zero Config/GlobalStates
// coupling in the original, a simple JSON-file-backed task list. Only
// change: Directories.todoPath (this plugin's own stubs/Directories.qml)
// points at THIS PLUGIN's own state dir
// (~/.local/state/omarchy/trevor.ii-control-center/todo.json) instead of a
// real ii install's ~/.local/state/quickshell/user/todo.json, so the two
// never clash.
Singleton {
    id: root
    property var filePath: Directories.todoPath
    property var list: []

    function addItem(item) {
        list.push(item);
        root.list = list.slice(0);
        todoFileView.setText(JSON.stringify(root.list));
    }

    function addTask(desc) {
        root.addItem({ "content": desc, "done": false });
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true;
            root.list = list.slice(0);
            todoFileView.setText(JSON.stringify(root.list));
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false;
            root.list = list.slice(0);
            todoFileView.setText(JSON.stringify(root.list));
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1);
            root.list = list.slice(0);
            todoFileView.setText(JSON.stringify(root.list));
        }
    }

    function refresh() {
        todoFileView.reload();
    }

    Component.onCompleted: root.refresh()

    FileView {
        id: todoFileView
        path: root.filePath
        onLoaded: {
            const fileContents = todoFileView.text();
            root.list = JSON.parse(fileContents);
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                root.list = [];
                todoFileView.setText(JSON.stringify(root.list));
            } else {
                console.log("[ii-control-center Todo] Error loading file: " + error);
            }
        }
    }
}
