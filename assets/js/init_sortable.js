import Sortable from "sortablejs"

export const InitSortable = {
  mounted() {
    const callback = list => {
      this.pushEventTo(this.el.dataset.targetId, "sort", { list: list })
    }

    this.init(callback)
  },
  init(callback) {
    const targetNode = this.el
    const sortable = new Sortable(targetNode, {
      onSort: evt => {
        const nodeList = targetNode.querySelectorAll("[data-sortable-id]")
        const list = [...nodeList].map((element, index) => (
          {
            id: element.dataset.sortableId,
            position: index
          }
        ))

        callback(list)
      }
    })
  }
}
