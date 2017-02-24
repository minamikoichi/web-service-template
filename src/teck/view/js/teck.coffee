root = exports ? this
root.appRouter = null
root.currentViewModel = null

# const
ESCAPED_FRAGMENT = "\\?_escaped_fragment_"

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
  root.currentViewModel = new TeckViewModel
  ko.applyBindings root.currentViewModel, $('html')[0]
  # update article.
  root.currentViewModel.init window.location.pathname + window.location.search
  # end page action settings
  $(window).scroll () ->
    if $(window).scrollTop() + $(window).height() == $(document).height()
      root.currentViewModel.endPageAction()
  
$ ->
  # ESCAPED_FRAGMENTが存在する場合はデータを返すだけのためrouting,bind処理不要
  path = window.location.pathname + window.location.search
  if path.match ESCAPED_FRAGMENT 
    return
  onReady()

