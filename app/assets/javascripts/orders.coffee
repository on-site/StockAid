showOrderDialog = (orderId) ->
  $.ajax
    url: "/orders/#{orderId}/show_order_dialog"
    type: "POST"
    dataType: "json"
    success: ({order_id, order_date, organization_name, status, order_details}) ->
      $("#order_id").text order_id
      $("#date_received").text order_date
      $("#organization_name").text organization_name
      $("#status").text status
      $("#edit_order_button").attr "href", "/orders/#{order_id}/edit"
      orderDetails = JSON.parse(order_details)
      html = []
      html.push("<tr><td>#{item.description}</td><td>#{item.quantity}</td></tr>") for item in orderDetails
      $("#order-details").html html.join("")
      $("#order_details_modal").modal()
    error: (jqXHR, textStatus, errorThrown) ->
      alert "Error occurred"

expose "orderRowClicked", (event, row, element) ->
  event.stopPropagation()
  orderId = row.data "order-id"
  showOrderDialog orderId

populateCategories = (element) ->
  for {id, description} in data.categories
    element.append "<option value='#{id}'>#{description}</option>"

populateItems = (category_id, element) ->
  id = parseInt category_id
  for category in data.categories
    if category.id is id
      currentCategory = category
  element.empty()
  element.append '<option value="">Select an item...</option>'
  for {id, description} in currentCategory.items
    element.append "<option value='#{id}'>#{description}</option>"

findLastCategory = ->
  orders = $('.well').find '.order'
  $(orders[orders.length-1]).find '#category'

$(document).on "change", ".form-control", (e) ->
  $(e.target).closest("form").submit()

$(document).on "click", ".add-item", (e) ->
  e.preventDefault()
  e.stopPropagation()
  $("#add_inventory_modal").modal("show")

$(document).on "click", "#add-item-row", (event) ->
  event.preventDefault();
  currentRows = $('.well').find('.order').length
  newRow = $("
    <tr class='order'>
      <td>
        <select id='category' class='form-control row-#{currentRows}'>
          <option value=''>Select a category...</option>
        </select>
      </td>
      <td>
        <select id='item' class='form-control row-#{currentRows}'>
          <option value=''>Select an item...</option>
        </select>
      </td>
      <td>
        <select id='quantity' class='form-control row-#{currentRows}'>
          <option value=''>0</option>
        </select>
      </td>
    </tr>
      ");
  category = newRow.find '#category'
  populateCategories category
  addListeners category
  $('table tbody').append newRow

addListeners = (element) ->
  element.on 'change', ->
    items = $(event.currentTarget.parentElement.parentElement).find '#item'
    populateItems @value, items

$(document).on 'page:change', ->
  element = findLastCategory()
  populateCategories element
  addListeners element
