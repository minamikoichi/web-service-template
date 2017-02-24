root = exports ? this
root.appRouter = null
root.currentViewModel = null

# back support
AppRouter = Backbone.Router.extend
  routes:
    '*splat' : 'popStateFunc'
      
  popStateFunc: (actions) ->
    returnLocation = history.location || document.location
    window.location = returnLocation
    root.currentViewModel.transition window.location.pathname + window.location.search

# initialize
onReady = () ->
  # router initialize
  root.appRouter = new AppRouter
  routerArgs =
    pushState:true
    root:"/"
    silent:true
  Backbone.history.start(routerArgs)
  # ViewModel initialize.
  root.currentViewModel = new BoardgameBlogViewModel
  ko.applyBindings root.currentViewModel, $('html')[0]
  # update article.
  root.currentViewModel.init window.location.pathname + window.location.search
  # end page action settings
  $(window).scroll () ->
    if $(window).scrollTop() + $(window).height() == $(document).height()
       root.currentViewModel.endPageAction()
  
$ ->
  onReady()
