-- Add Qt file type detection
vim.filetype.add({
    extension = {
        ui = "xml",          -- Qt Designer files
        qrc = "xml",         -- Qt Resource files
        pro = "make",        -- Qt Project files
        pri = "make",        -- Qt Include files
        qml = "qml",         -- QML files
        qmldir = "qml",      -- QML directory files
    },
    pattern = {
        [".*%.pro%.user"] = "json",  -- Qt Creator user files
    }
})

-- Qt-specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "cpp", "c" },
    callback = function()
        -- Set Qt-specific options
        vim.opt_local.commentstring = "// %s"
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.expandtab = true
        
        -- Add Qt keywords for syntax highlighting
        vim.cmd([[
            syntax keyword cppType QString QStringList QList QVector QMap QHash
            syntax keyword cppType QObject QWidget QApplication QMainWindow
            syntax keyword cppType QLabel QPushButton QLineEdit QTextEdit
            syntax keyword cppType QVBoxLayout QHBoxLayout QGridLayout
            syntax keyword cppType QTimer QThread QMutex QSemaphore
            syntax keyword cppType QFile QDir QIODevice QNetworkAccessManager
            syntax keyword cppType QJsonDocument QJsonObject QJsonArray
        ]])
    end,
})
