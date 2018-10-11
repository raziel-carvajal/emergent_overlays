const assert = require('assert')
const express = require('express')
const loggerD = require('morgan')
const logI = require('debug')('ini-f-d')

if (!process.env.INI_FILES_LIST || process.env.INI_FILES_LIST === '') {
  logI('Error: list of INI files do not exist')
  process.exit(1)
}
const fs = require('fs'), path = require('path')
const fsPath = path.join(__dirname, process.env.INI_FILES_LIST)

var iniFiles = fs.readFileSync(fsPath)
assert(typeof(iniFiles) === 'object')
iniFiles = `${iniFiles}`.split('\n')
var iniFilesAr = []
for (var i = 0; i < iniFiles.length; i++)
  if (iniFiles[i] !== '') iniFilesAr.push(iniFiles[i])

const daemon = express()
daemon.use(loggerD('dev'))
daemon.use(function(req, res, next) {
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'GET, PUT, POST, DELETE')
  next()
})

daemon.get('/ini_file', function (req, res) {
  res.setHeader('Content-Type', 'text/html')
  logI(iniFilesAr)
  res.send(iniFilesAr.length !== 0 ? iniFilesAr.pop() : '')
})

const port = process.env.INI_F_D_PORT ? process.env.INI_F_D_PORT : 80
daemon.listen(port, function () {
  console.log(`Server listening on port ${port}!`)
})
