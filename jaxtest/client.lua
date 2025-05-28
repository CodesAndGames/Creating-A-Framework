print('test')

exports['jaxmenu']:RegisterMenu('main',{
  {
    label   = 'Opacity',
		export 	= 'setOpacity',
		resourceName = 'jaxtest'
		isServer = false,
    choices = {1, 2, 3, 4, 5},
  },
})

exports("setOpacity",function(newOpacity)
	print(newOpacity..' new opactiy')
end)