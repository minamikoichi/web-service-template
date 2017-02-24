root = exports ? this

setMaxImage = () ->
  $('.bgmaximage').maximage
    isBackground: true
    overflow: 'auto'
    position: ('fixed')
    verticalAlign:'top'
    horizontalAlign:'right'
    maxFollows: 'height'
