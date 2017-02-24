oroot = exports ? this

# const admin
ADMINPATH     = '/admin/'
NEW_ITEM_QUERY         = ADMINPATH + 'newitem/'
NEW_ITEM_POST_QUERY    = ADMINPATH + 'newitem/post/'
NEW_ITEM_PREVIEW_QUERY = ADMINPATH + 'newitem/preview/'
ADMIN_BLOG_MENU = [
  name  : "新規投稿",
  value : ""
]
EDIT_ITEM_QUERY         = ADMINPATH + "edititem/"
EDIT_ITEM_COMMIT_QUERY  = ADMINPATH + "edititem/commit/"
EDIT_ITEM_PREVIEW_QUERY = ADMINPATH + "edititem/preview/"
DELETE_ITEM_QUERY       = ADMINPATH + "deleteitem/"

GAMELIST_UPDATE_QUERY       = ADMINPATH + "gamelist/update/"

# const boardgame
ROOTPATH     = '/boardgame/'
PAGEQUERY    = ROOTPATH + 'view/page/'
IDQUERY      = ROOTPATH + 'view/id/'
ARCHIVEQUERY = ROOTPATH + 'archive/'
ARCHIVE_TAG  = [
  name  : "全て",
  value : "*"
,
  name : "レビュー",
  value : "レビュー"  
,
  name : "ゲーム会",
  value : "ゲーム会"  
,
  name : "まとめ",
  value : "まとめ"  
]
GAMELISTQUERY = ROOTPATH + 'gamelist/'
GAMELIST_MENU = [
  name : "評価順",
  value: "gamelist-rating"
,
  name : "年代順",
  value: "gamelist-year-published"
]
RATING = [
  name : "お気に入り",
  value: 10
,
  name : "最高",
  value: 9
,
  name : "面白い",
  value: 8
,
  name : "その他",
  value: 0
,
  name : "未プレイ",
  value: -1  
]

# function
makeLocation = ( path ) ->
  location = window.location.protocol + '//' + window.location.host + path

separateObjectArray = (array , keyGetter) ->
  separateList = {}
  keyList = []
  for obj in array
    key = keyGetter(obj)
    if key of separateList
      separateList[key].push obj
    else
      separateList[key] = []
      separateList[key].push obj
      keyList.push key
  [separateList , keyList]

# page title binding
ko.bindingHandlers.pageTitle = 
  update: (element, valueAccessor) ->
    title = ko.utils.unwrapObservable valueAccessor()
    document.title = title

ko.virtualElements.allowedBindings.pageTitle = true

# ViewModel
class BoardgameBlogViewModel
  constructor: () ->
    ################################################## 
    # variables 
    ##################################################
    # observable variables 
    @title = ko.observable '日曜ボードゲーム'
    @discription = ko.observable 'ボードゲームのことを書くサイト'
    @titleText = ko.computed (() -> return @title() + " : " + @discription()), @
    @articleType = ko.observable 'blog-item-summary'    
    @article = ko.observableArray []
    @tags = ko.observableArray ARCHIVE_TAG
    @archive = ko.observableArray []
    @gamelistMenu = ko.observableArray GAMELIST_MENU
    @gamelist = ko.observableArray []
    @gamelistViewMode = ko.observable 'gamelist-rating' #初期値はgamelist-rating
    # admin
    @adminBlogMenu = ko.observable ADMIN_BLOG_MENU
    @newItemTitle  = ko.observable ''
    @newItemText   = ko.observable ''
    @newItemTags   = ko.observable ''
    @editItemId    = ko.observable 0
    @editItemDate  = ko.observable ''
    @editItemTitle = ko.observable ''
    @editItemText  = ko.observable ''
    @editItemTags  = ko.observable ''    
    @previewHtml   = ko.observable ''
    # working variables     
    @blogItem = [] # データは日付順に並べる
    @nextPollPageNumber = 1
    ################################################## 
    # path - articleType mapping
    ##################################################
    @getArticleTypeFromPath = (path) ->
      if      path is ADMINPATH
        'blog-item-summary'        
      else if path is NEW_ITEM_QUERY
        'blog-new-item'
      else if path is EDIT_ITEM_QUERY
        'blog-edit-item'
      else if path is ROOTPATH
        'blog-item-summary'
      else if path.match PAGEQUERY+"([0-9]+)"
        'blog-item-summary'
      else if path.match IDQUERY+"([0-9]+)"
        'blog-item'        
      else if path.match ARCHIVEQUERY
        'blog-archive'
      else if path.match GAMELISTQUERY
        'gamelist'
      else
        'blog-item-summary'
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
      if path is ADMINPATH
        @nextPollPageNumber = 1        
        @pullBlogItem false
      else if path is ROOTPATH
        @nextPollPageNumber = 1        
        @pullBlogItem false
      else if path.match PAGEQUERY+"([0-9]+)"
        ret = path.match PAGEQUERY+"([0-9]+)"
        pageNumber = parseInt ret[1]
        @nextPollPageNumber = pageNumber
        @pullBlogItem false
      else
        type = @getArticleTypeFromPath path
        updateFunc = null
        if type is 'blog-archive'
          updateFunc = @archiveUpdate
        else if type is 'gamelist'
          updateFunc = @gamelistUpdate
        else 
          updateFunc = @articleUpdate
        @transition path, updateFunc, false
    @archiveInit = (data,event) ->
      # isotype filter
      $container = $('.isotope').isotope 
        itemSelector: '.element-item'
        layoutMode: 'fitRows'
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
      path = '/boardgame/view/id/' + dstId + '/'
      # 既に取得している場合はそれを表示する
      item = _.find @blogItem , (i) -> i.id == dstId      
      if item
        $('article').fadeOut 'slow', () ->
          vm.articleUpdate vm, path, [item]
          $('article').fadeIn 1500          
      else
        @transition path, @articleUpdate , true
    @archiveLinkClick = (data, event) ->
      # jump archive page (with animation).
      @transition ARCHIVEQUERY, @archiveUpdate, true
    @gamelistLinkClick = (data, event) ->
      # jump gamelist page (with animation).
      @transition GAMELISTQUERY, @gamelistUpdate, true      
    ################################################## 
    # blog
    ##################################################      
    @pullBlogItem = (animation) ->
      # ページ単位でのblogデータ取得
      # animationはcustom bindingによりtemplate更新時に実行したいがtemplateのupdateがcallされない現象があるため妥協      
      vm = @
      $.ajax '/data/boardgame/view/page/' + @nextPollPageNumber + '/',
        type : 'GET',
        dataType: 'json',
        success: (data, textStatus, jqXHR) ->
          unless vm.articleType() == 'blog-item-summary'
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
      if @articleType() == 'blog-item-summary'
        @pullBlogItem false
    @getRecommendThumbnail = (thumbnail) ->
      unless thumbnail
        return ''
      thumbnail.replace /_z.jpg/, '_m.jpg'
    @getShowDate = (date) ->
      unless date
        return ''
      date.replace /T(.*)/, ''
    ################################################## 
    # archive 
    ##################################################        
    @archiveUpdate = (vm, path, itemList) ->
      vm.archive.removeAll()
      $('html, body').animate scrollTop: 0 , 0
      vm.archive.push.apply vm.archive, itemList
      vm.updatePathAndArticleType path
    @archiveTagFilterClick = (name, data, event) ->
      $container = $('.archive').isotope
        itemSelector: '.archive-section',
        layoutMode: 'fitRows'
      filter = name
      if name isnt '*'        
        filter = (el) ->          
          tagElList = $(this).find('.tag')
          for tagEl in tagElList
            if tagEl.innerText is name
              return true
          return false
      $container.isotope( filter: filter )
    @getArchiveThumbnail = (thumbnail) ->
      unless thumbnail
        return ''
      thumbnail.replace /_z.jpg/, '_n.jpg'
    @tagsToList = (tags) -> 
      unless tags
        return []
      return tags.split(',')                 
    ################################################## 
    # gamelist
    ##################################################        
    @gamelistUpdate = (vm, path, gamelist) ->
      vm.gamelist.removeAll()
      vm.gamelist.push.apply vm.gamelist, gamelist
      vm.updatePathAndArticleType path
    @gamelistViewModeChange = (mode, data, event) ->
      @gamelistViewMode mode
    @yearPublishGamelist = () ->
      # 所持しておらずレーティングもないゲームは除外する
      useGamelist = _.filter @gamelist() , (i) -> (i.own isnt "f") or (i.rating isnt null)
      # ゲームを年代別に分ける
      [separateGamelist, useYearList] = separateObjectArray useGamelist , (i) -> i.yearpublished
      # 表示用に並び替え          
      yearList = _.sortBy useYearList , (y) -> return y      
      sortedGameList = []
      for year in yearList
        yearGameList = {}
        yearGameList.name = year
        yearGameList.gamelist = []
        yearGameList.gamelist.push.apply yearGameList.gamelist, separateGamelist[year]
        sortedGameList.push yearGameList
      sortedGameList
    @ratingGamelist = () ->
      #ゲームをレーティングで分ける
      ratingMapper = (v) ->
        for r in RATING
          rate = v.rating
          if rate is null
            rate = -1
          if rate >= r.value
            return r.name
      useGamelist = _.filter @gamelist() , (i) -> (i.own isnt "f") or (i.rating isnt null)
      [separateGamelist, useRatingList] = separateObjectArray useGamelist , ratingMapper
      # 表示用に並び替え
      sortedGameList = []
      for rating in RATING
        oneListGroup = {}
        oneListGroup.name = rating.name
        oneListGroup.gamelist = []
        if rating.name of separateGamelist
          oneListGroup.gamelist.push.apply  oneListGroup.gamelist, separateGamelist[rating.name]
          sortedGameList.push oneListGroup
      sortedGameList            
    @getSquareThumbnailLink = (thumbnail) ->
      unless thumbnail
        return ""
      thumbnail.replace /_t.jpg/, '_sq.jpg'
    @getRatingBorder = (rating) ->
      unless rating
        return ""
      if rating >= 9
        return "gold-border"
      else if rating >= 8
        return "grey-border"
      else
        return ""
    ################################################## 
    # admin
    ##################################################
    @deleteItemButtonClick = ( id , data , event ) ->
      vm = @
      postparams =
        "id" : id
      $.post '/data' + DELETE_ITEM_QUERY, postparams, ( data ) ->
        window.location.reload() 
    @editItemButtonClick = ( id , data , event ) ->
      vm = @
      path = EDIT_ITEM_QUERY
      item = _.find @blogItem , (i) -> i.id == id
      postparams =
        "id" : id,
      $.post '/data' + path , postparams, (data) ->
        vm.editItemId item.id
        vm.editItemDate  item.date 
        vm.editItemTitle item.title
        vm.editItemTags  item.tags  
        vm.editItemText  data
        vm.updatePathAndArticleType path
    @commitEditItemClick = (date, event) ->
      vm = @
      path = EDIT_ITEM_COMMIT_QUERY
      postparams =
        "id"    : @editItemId(),
        "title" : @editItemTitle(),
        "text"  : @editItemText(),
        "tags"  : @editItemTags()
      if postparams.title isnt "" and postparams.text isnt "" and postparams.id
        $.ajax '/data' + path,
          type : 'POST',
          dataType: 'json',
          data : postparams,
          success: (data, textStatus, jqXHR) ->
            vm.transition ADMINPATH, vm.articleUpdate, true
            window.location.reload true
    @newItemLinkClick = (data,event) ->
      vm = @
      path = NEW_ITEM_QUERY
      vm.previewHtml ""
      vm.updatePathAndArticleType path
    @previewToday = () ->
      today = new Date()
      return today.getFullYear() + "-" + ( today.getMonth() + 1 ) + "-" + today.getDate()
    @previewItemClick = (text,data,event) ->
      vm = @
      path = NEW_ITEM_PREVIEW_QUERY
      postparams =
        "text"  : text,
      if postparams.title isnt ""
        $.ajax '/data' + path,
          type : 'POST',
          dataType: 'json',
          data : postparams,
          success: (data, textStatus, jqXHR) ->
            vm.previewHtml data
    @postItemClick = (data,event) ->
      vm = @
      path = NEW_ITEM_POST_QUERY
      postparams =
        "title" : @newItemTitle(),
        "text"  : @newItemText(),
        "tags"  : @newItemTags()
      if postparams.title isnt "" and postparams.text isnt ""
        $.ajax '/data' + path,
          type : 'POST',
          dataType: 'json',
          data : postparams,
          success: (data, textStatus, jqXHR) ->
            vm.transition ROOTPATH, vm.articleUpdate, true
    ################################################## 
    # admin gamelist
    ##################################################
    @gamelistDbUpdate = (data , event) ->
      vm = @
      $.ajax '/data' + GAMELIST_UPDATE_QUERY,
        type : 'POST',
        dataType: 'json',
        success: (data, textStatus, jqXHR) ->
          vm.transition GAMELISTQUERY, vm.articleUpdate, true
