root = exports ? this

# const 
ROOTPATH     = '/teck/'
PAGEQUERY    = ROOTPATH + 'view/page/'
IDQUERY      = ROOTPATH + 'view/id/'
ARCHIVEQUERY = ROOTPATH + 'archive/'
ARCHIVE_TAG  = [
  name  : "全て",
  value : "*"
]

# function
makeLocation = ( path ) ->
  location = window.location.protocol + '//' + window.location.host + path

# page title binding
ko.bindingHandlers.pageTitle = 
  update: (element, valueAccessor) ->
    title = ko.utils.unwrapObservable valueAccessor()
    document.title = title

ko.virtualElements.allowedBindings.pageTitle = true

# ViewModel
class TeckViewModel
  constructor: () ->
    ################################################## 
    # variables 
    ##################################################
    # observable variables 
    @title = ko.observable '土曜Lisp'
    @discription = ko.observable 'Lispメインに技術ネタを記載するサイト'
    @titleText = ko.computed (() -> return @title() + " : " + @discription()), @
    @article     = ko.observableArray []
    @articleType = ko.observable 'blog-item'
    @recentEntry = ko.observableArray []
    # working variables     
    @blogItem = [] # データは日付順に並べる
    @nextPollPageNumber = 1
    ################################################## 
    # path - articleType mapping
    ##################################################
    @getArticleTypeFromPath = (path) ->
      if      path is ROOTPATH
        'blog-item'
      else if path.match PAGEQUERY+"([0-9]+)"
        'blog-item'
      else if path.match IDQUERY+"([0-9]+)"
        'blog-item-single'        
      else
        'blog-item'
    @updatePathAndArticleType = (path) ->
      # if document.location.pathname isnt path
      type = @getArticleTypeFromPath path
      @articleType type
      root.appRouter.navigate path         
    ################################################## 
    # initialize
    ##################################################        
    @init = (path) ->
      # 初期処理.アクセスされたpathのデータを取得してanimation無しで表示する。      
      vm = @
      @getRecentEntry()
      if path is ROOTPATH
        @nextPollPageNumber = 1        
        @pullBlogItem false
      else if path.match PAGEQUERY+"([0-9]+)"
        ret = path.match PAGEQUERY+"([0-9]+)"
        pageNumber = parseInt ret[1]
        @nextPollPageNumber = pageNumber
        @pullBlogItem false
      else
        type = @getArticleTypeFromPath path        
        updateFunc = @articleUpdate
        @transition path, updateFunc, false      
    ################################################## 
    # page link action 
    ##################################################
    @topLinkClick = (data,event) ->
      # reset counter and jump toppage (with animation).
      @nextPollPageNumber = 1
      @transition ROOTPATH, @articleUpdate, true
    @itemLinkClick = (dstId,data,event) ->
      # jump blog item page (with animation).
      vm = @
      path = '/teck/view/id/' + dstId + '/'
      # 既に取得している場合はそれを表示する
      item = _.find @blogItem , (i) -> i.id == dstId      
      if item
        $('article').fadeOut 'slow', () ->
          vm.articleUpdate vm, path, [item]
          $('article').fadeIn 1500          
      else
        @transition path, @articleUpdate , true
    ################################################## 
    # blog
    ##################################################      
    @pullBlogItem = (animation) ->
      # ページ単位でのblogデータ取得
      # animationはcustom bindingによりtemplate更新時に実行したいがtemplateのupdateがcallされない現象があるため妥協      
      vm = @
      $.ajax '/data/teck/view/page/' + @nextPollPageNumber + '/',
        type : 'GET',
        dataType: 'json',
        success: (data, textStatus, jqXHR) ->
          unless vm.articleType() == 'blog-item'
            return
          vm.nextPollPageNumber++
          if animation
            $('article').fadeOut 'slow', () ->
              vm.articleAppend data.data
              $('article').fadeIn 1500              
          else
            vm.articleAppend data.data
    @transition = (path, updateFunc, animation) ->
      # ページデータを取得して遷移する
      vm = @      
      $.ajax '/data' + path,
        type : 'GET',
        cache: true,
        dataType: 'json',
        success: (data, textStatus, jqXHR) ->
          if animation
            $('article').fadeOut 'slow', () ->
              updateFunc vm, path, data.data
              $('article').fadeIn 1500
          else
            updateFunc vm, path, data.data
    @articleUpdate = (vm, path, itemList) ->
      vm.article.removeAll()
      $('html, body').animate scrollTop: 0 , 0
      vm.updatePathAndArticleType path
      vm.article.push.apply vm.article, itemList
      vm.blogItem.push.apply vm.blogItem, itemList
      _.sortBy vm.blogItem , (d) -> return d.date
    @articleAppend = (itemList) ->
      for item in itemList
        unless (_.find @article , (i) -> i.id == item.id)
          @article.push item
          @blogItem.push item
      _.sortBy @blogItem , (d) -> return d.date
    # ページ末尾到達時の処理
    @endPageAction = () ->
      if @articleType() == 'blog-item'
        @pullBlogItem false
    @getRecentEntry = () ->
      vm = @
      $.ajax '/data/teck/view/page/1/',
        type : 'GET',
        dataType: 'json',
        success: (data, textStatus, jqXHR) ->
          vm.recentEntry.push.apply vm.recentEntry, data.data        
    @getShowDate = (date) ->
      unless date
        return ''
      date.replace /T(.*)/, ''
      
