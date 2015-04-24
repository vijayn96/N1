Reflux = require 'reflux'
_ = require 'underscore-plus'
fs = require 'fs'

{WorkspaceStore,
 FocusedContentStore,
 FileDownloadStore,
 Actions} = require 'inbox-exports'

module.exports =
FileFrameStore = Reflux.createStore
  init: ->
    @_resetInstanceVars()
    @_afterViewUpdate = []

    @listenTo FocusedContentStore, @_onFocusedContentChange
    @listenTo FileDownloadStore, @_onFileDownloadChange

  file: ->
    @_file

  ready: ->
    @_ready

  download: ->
    @_download

  _resetInstanceVars: ->
    @_file = null
    @_download = null
    @_ready = false

  _update: ->

  _onFileDownloadChange: ->
    @_download = FileDownloadStore.downloadForFileId(@_file.id) if @_file
    if @_file and @_ready is false and not @_download
      @_ready = true
      @trigger()

  _onFocusedContentChange: (change) ->
    return unless change.impactsCollection('file')

    @_file = FocusedContentStore.focused('file')
    if @_file
      filepath = FileDownloadStore.pathForFile(@_file)
      fs.exists filepath, (exists) =>
        Actions.fetchFile(@_file) if not exists
        @_download = FileDownloadStore.downloadForFileId(@_file.id)
        @_ready = not @_download
        @trigger()
    else
      @_ready = false
      @_download = null
      @trigger()