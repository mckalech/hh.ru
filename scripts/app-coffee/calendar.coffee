define ['jquery', 'utils', 'header', 'data'], ($, utils, Header, Data) ->
	class Calendar 
		today		:	new Date()
		curDate		:	new Date()
		$td 		: 	null
		$curTd 		: 	null
		
		constructor: () ->
			@initHtml()
			@data = new Data(this)
			@header = new Header(this)
			@fullContainer()
			@bindHandlers()
		initHtml : () ->
			@$saveBtn 	= 	$('.save')
			@$delBtn 	= 	$('.delete')
			@$searchQ 	= 	$('.search')
			@$searchSug	= 	$('.sug')
			@$warning 	= 	$('.warning')
			@$popup 	= 	$('.cal__popup')
			@$elem 		= 	$('.container')
			return

		bindHandlers : () ->
			@$searchQ.bind 'keyup', (e) =>
				query = $(e.currentTarget).val()
				data = @data.getData()
				isWords = no
				@$searchSug.html('')
				if query.length>2
					@$searchSug.show()
					isWords = no
					for index, value of data			
						if value.descr.toLowerCase().indexOf(query.toLowerCase())>=0
							replStr = value.descr.replaceAll(query,"<b>#{query}</b>")
							@$searchSug.append("<li data-date='#{index}'><p>#{replStr}</p><span>#{index.split('-')[0]} #{utils.monthSklon[index.split('-')[1]]}</span></li")
							isWords = yes
						else if value.name.indexOf(query)>=0
							replStr = value.name.replaceAll(query,"<b>#{query}</b>")
							@$searchSug.append("<li data-date='#{index}'><p>#{replStr}</p><span>#{index.split('-')[0]} #{utils.monthSklon[index.split('-')[1]]}</span></li")
							isWords = yes
					@$searchSug.hide() unless isWords
				else
					@$searchSug.hide()
				return
			
			@$searchSug.on 'click', 'li', (e)=>
				dateMas=$(e.currentTarget).attr('data-date').split('-')
				@curDate.setMonth(dateMas[1])
				@curDate.setYear(dateMas[2])
				@fullContainer()
				@$searchSug.html('').hide()
				@$searchQ.val('')
				return
			
			@$popup.find('.close').on 'click', () =>
				@hidePopup()
				return
			
			@$popup.find('input, textarea').on 'blur', (e)=>			
				text = $(e.currentTarget).val()
				$(e.currentTarget).siblings('span').text(text) 
				if text then $(e.currentTarget).parent().removeClass('empty')
				return

			@$popup.on 'click', '.edit span', (e)=>
				text = $(e.currentTarget).text()
				$(e.currentTarget).parent().addClass('empty').find('input, textarea').val(text).focus()
				return
			
			@$elem.on 'click', '.item', (e)=> 
				@showPopup({x:e.clientX,y:e.clientY})
				@setCurTd($(e.currentTarget))
				@$popup.find('.date span').text("#{@$curTd.attr('data-date')} #{utils.monthSklon[@curDate.getMonth()]}")		
				if @$curTd.hasClass('full')				
					@$popup.find('.description').removeClass('empty').find('span').text(@$curTd.attr('data-descr'))
					@$popup.find('.name').removeClass('empty').find('span').text(@$curTd.attr('data-name'))
				else
					@$popup.find('.description, .name').addClass('empty').find('span').text('')
					@$popup.find('input, textarea').val('')
				return
			
			@$saveBtn.on 'click', ()=>
				description = @$popup.find('.description').find('span').text()
				name = @$popup.find('.name').find('span').text()
				if description and name	
					@saveItem()
				else unless description or name	
					@deleteItem()
				else
					@$warning.addClass('visible')
				return		

			@$delBtn.on 'click', ()=>
				@deleteItem()
				return

			return

		prevMonth : () ->
			@curDate.setMonth(@curDate.getMonth()-1)
			return

		nextMonth : () ->
			@curDate.setMonth(@curDate.getMonth()+1)
			return
			
		fullContainer : () ->
			d=1
			data = @data.getData()
			@$elem.html('<table id="main-table" cellpadding=0 cellspacing=0 />');
			for i in [0...@curDate.weeksInMonth()]		
				if i>@curDate.weeksInMonth() then break;
				@$elem.find('table').append('<tr />')
				j = 0
				while j<@curDate.firstDayInMonth() and i==0 					
					@$elem.find('tr').append("<td><div class='date'>#{utils.days[j]}</div></td>")
					j++
				
				for j in [j...7]
					newTd = $('<td />').appendTo(@$elem.find('tr').last())
					if d>@curDate.daysInMonth() then continue					
					dayText =  if i==0 then "#{utils.days[j]}, #{d}" else d					
					newTd.append("<div class='date'>#{dayText}</div><p class='name'></p><p class='descr'></p>").attr('data-date',d).addClass('item').addClass(if d==@today.getDate() and @curDate.getMonth()==@today.getMonth() and @curDate.getYear()==@today.getYear() then 'today' else '');
					d++
			
			for key of data		
				dateMas = key.split('-').map((el)->parseInt(el))
				d = dateMas[0]
				m = dateMas[1]
				y = dateMas[2]
				if data[key] and @curDate.getMonth()==m and @curDate.getFullYear()==y
					@$elem.find("td[data-date='#{d}']")
						.attr('data-descr',data[key].descr)
						.attr('data-name',data[key].name)
						.addClass('full').find('.name').text(data[key].name)
						.siblings('.descr').text(data[key].descr)
			
			@header.$monthElem.text("#{utils.months[@curDate.getMonth()]} #{@curDate.getFullYear()}")
			@$td = @$elem.find('.item')	
			return
			
		showPopup: (opt) ->
			newX = opt.x
			newY = opt.y
			@$popup.css({ top: newY-30, left: newX+20}).fadeIn(100)
			@$warning.removeClass('visible')
			return
		
		hidePopup:() ->
			@$popup.fadeOut(100)
			@setCurTd(null)
			return

		saveItem:() ->
			@$curTd
				.attr('data-descr',@$popup.find('.description').find('span').text())
				.attr('data-name',@$popup.find('.name').find('span').text())
				.addClass('full')
				.find('.name').text(@$popup.find('.name').find('span').text())
				.siblings('.descr').text(@$popup.find('.description').find('span').text())
			options = {
				day : @$curTd.attr('data-date')
				curDate : @curDate
				descr : @$curTd.attr('data-descr')
				name : @$curTd.attr('data-name')
			}
			@data.setData(options, yes)	
			@$popup.find('input, textarea').val('')			
			@hidePopup()
			return 

		deleteItem:() ->
			@$curTd
				.removeAttr('data-descr')
				.removeAttr('data-name')
				.removeClass('full')
				.find('p').text('')
			options = {
				day : @$curTd.attr('data-date')
				curDate : @curDate
			}
			@data.setData(options, no)
			@$popup.find('input, textarea').val('')
			@hidePopup()
			return

		setCurTd : ($tdElem) ->
			@$curTd = $tdElem;
			@$td.removeClass('active');
			if @$curTd
				@$curTd.addClass('active');
			return
			
	return Calendar

