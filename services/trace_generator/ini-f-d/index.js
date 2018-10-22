const assert = require('assert')
const express = require('express')
const loggerD = require('morgan')
const bodyParser = require('body-parser')

const logI = require('debug')('ini-f-d')

if (!process.env.INI_FILES_LIST || process.env.INI_FILES_LIST === '') {
  logI('Error: list of INI files do not exist')
  process.exit(1)
}
if (!process.env.INI_FILES_DIR || process.env.INI_FILES_DIR === '') {
  logI("'Error: directory of configuration files wasn't defined")
  process.exit(1)
}

const fs = require('fs')
const path = require('path')
const fsPath = path.join(process.env.INI_FILES_DIR, process.env.INI_FILES_LIST)

var iniFiles = fs.readFileSync(fsPath)
assert(typeof (iniFiles) === 'object')
iniFiles = `${iniFiles}`.split('\n')

var iniFilesAr = []
var i
for (i = 0; i < iniFiles.length; i++) {
  if (iniFiles[i] !== '') iniFilesAr.push(iniFiles[i])
}

const daemon = express()
daemon.use(loggerD('dev'))
daemon.use(bodyParser.json())
daemon.use(bodyParser.urlencoded({ extended: false }))
daemon.use(function (req, res, next) {
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'GET, PUT, POST, DELETE')
  next()
})

daemon.get('/alive', function (req, res) {
  res.setHeader('Content-Type', 'text/html')
  res.send('Y')
})

daemon.get('/ini_file', function (req, res) {
  res.setHeader('Content-Type', 'text/html')
  logI(iniFilesAr)
  res.send(iniFilesAr.length !== 0 ? iniFilesAr.pop() : '')
})

var completedTasks = []
daemon.post('/completed_task', function (req, res) {
  logI(`New completed task: ${req.body.task}`)
  completedTasks.push(req.body.task)
  res.setHeader('Content-Type', 'text/html')
  res.send('Ok')
})

daemon.get('/dataset_to_plot', function (req, res) {
  logI('New request to plot broadcast metrics, current datasets:')
  logI(completedTasks)
  res.setHeader('Content-Type', 'text/html')
  res.send(completedTasks.length !== 0 ? completedTasks.pop() : '')
})

// in case you want to alter the list of dispatched configuration files
if (process.env.NEW_LIST && process.env.NEW_LIST !== '') {
  var newList = process.env.NEW_LIST.split(' ')
  if (newList.length !== 0) {
    var tmpList = []
    for (i = 0; i < newList.length; i++) {
      try {
        fs.readFileSync(path.join(process.env.INI_FILES_DIR, newList[i]))
        tmpList.push(newList[i])
        logI(`New configuration: ${newList[i]}`)
      } catch (e) {
        logI(`Configuration file ${newList[i]} do not exist`)
      }
    }
    if (tmpList.length !== 0) {
      logI('Updating list of configuration files')
      iniFilesAr = tmpList
      logI(iniFilesAr)
    }
  }
}

const port = process.env.INI_F_D_PORT ? process.env.INI_F_D_PORT : 80
daemon.listen(port, function () {
  logI(`Server listening on port ${port}!`)
})
