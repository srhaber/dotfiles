'use babel'

import { SelectListView, TextEditorView } from 'atom-space-pen-views'
import * as listViewFormatter from '../utils/listViewFormatter'

class InputWorkspaceNameView extends SelectListView {

  constructor (savedWorkspaces, callback) {
    super()
    this.callback = callback
    this.savedWorkspaces = savedWorkspaces
  }

  show (panel) {
    this.panel = panel

    if (this.panel.isVisible())
      return

    if (this.savedWorkspaces && Object.keys(this.savedWorkspaces).length > 0) {
      let items = listViewFormatter.formatWorkspaces(this.savedWorkspaces)
      this.setItems(items)
    } else {
      this.setItems([])
    }

    this.panel.show()

    this.storeFocusedElement()
    this.filterEditorView.focus()
  }

  close () {
    if (!this.panel.isVisible())
      return

    this.filterEditorView.setText('')

    this.restoreFocus()

    this.panel.hide()
  }

  confirmed (item) {
    const result = item.name
    this.callback(result)
    this.close()
  }

  cancelled () {
    const result = this.getFilterQuery()

    this.callback(result)
    this.close()
  }

  getFilterKey () {
    return 'name'
  }

  viewForItem (item) {
    let li = document.createElement('li')
    li.textContent = item.name
    return li
  }
}

InputWorkspaceNameView.content = function () {
  return this.div({class: 'select-list'}, () => {
    this.subview('filterEditorView', new TextEditorView({
      mini: true,
      placeholderText: 'Enter workspace name..'
    }))
    this.div({class: 'error-message', outlet: 'error'})
    this.div({class: 'loading', outlet: 'loadingArea'}, () => {
      this.span({class: 'loading-message', outlet: 'loading'})
      this.span({class: 'badge', outlet: 'loadingBadge'})
    })
    this.ol({class: 'list-group', outlet: 'list'})
  })
}

export default InputWorkspaceNameView
