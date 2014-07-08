$(function(){
  $('.fa-question-circle').tooltip();
  init_datetime_picker();
  $('#event_address').val($('option:selected',$(this)).data('address'));

  $('#event_venue_uuid').change(function(){
    $('#event_address').val($('option:selected',$(this)).data('address'));
    if($('option:selected',$(this)).data('address') == ''){
//      $('#new_venue_modal').modal('show');
      $("#event_venue_name").show();
      $("#event_address").attr('readonly', false);
      $(this).hide();
    }else{
      locationAjax();
    }
  })

  $('#event_cost_type').change(function(){
    var val = $('option:selected',$(this)).attr('value');
    if( val == 'free' || val == 'donation' || val == '' ){
      $('#event_price').hide();
      $('#event_price').val('');
      $('#event_end_price').hide();
      $('#event_end_price').val('');
    }else if( val == 'set_price'){
      $('#event_price').show();
      $('#event_end_price').hide();
      $('#event_end_price').val('');
    }else if( val == 'sliding_scale'){
      $('#event_price').show();
      $('#event_end_price').show();
    }
  });
  $('#event_rsvp').bootstrapSwitch({
    onInit: function(event, state){
      if($('#event_rsvp').is(':checked')){
        $('.yes').stop(true, true).slideDown();
      }else{
        $('.no').stop(true, true).slideDown();
      }
    }
  });
  $('#event_rsvp').on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      $('.no').stop(true, true).slideUp();
      $('.yes').stop(true, true).slideDown();
    }else{
      $('.yes').stop(true, true).slideUp();
      $('#event_max_attendees').val('');
      $('.no').stop(true, true).slideDown();
    }
  });


  $( '#organizations_name').autocomplete({
    minLength: 2,
    source: function( request, response ) {
      $.ajax({
        dataType: 'json',
        url: $('#autocomplete_organizations').attr('href'),
        data: {'organization[name]': request['term']},
        success: function(data, status, xhr){
          response(data);

        },
        error: function(){

        }

      });
    },
    select: function(event, ui){
      addOrganization();
    }
  });


  $(document).on({
    keypress: function(e){
      if(e.which == 13 ){
        e.preventDefault();
        addOrganization();
      }
    }
  }, '#organizations_name');


  $(document).on({
    click: function(e){
      e.preventDefault();
      addOrganization();
    }
  }, '.add_organization');


  $(document).on({
    click: function(e){
      e.preventDefault();
      $(this).closest('.row').slideUp(function(){
        $(this).remove();
      })
    }
  }, '.remove_organization');




  $(document).on({
    keyup: $.debounce( 1000, function(){
      $('.has-error').removeClass('has-error');
      $('.help-block').remove();
      $('.multiselect-location-container').data('change', '1');
      locationAjax();

    })
  }, "#event_address");


  $(document).on({
    click: function(e){
      e.preventDefault();
      var _this = $(this);
      var _div  =  $('.multiselect-location-container');
      var _l = Ladda.create(this);
      _l.start();
      if(!_div.is(':hidden') || (_div.is(':hidden') && _div.text().replace(/[\s\r\n]*/,'') == '') ||  _div.data('change')!="1" ) {
        $('.ajax-form').ajaxSubmit({
          dataType: 'json',
          success: eventSuccess,
          error: eventError,
          complete: function () {
            _l.stop();
          }
        })
      }else{
        $('.event-form-container').slideUp();
        _div.slideDown();
        $("html, body").animate({ scrollTop: 0 }, "slow");
        _div.data('change', '0');
        _l.stop();
      }
    }

  }, ".ajax-form [type='submit'], .event-save");

  $(document).on({
    click: function(e){
      e.preventDefault();
      var _this = $(this);
      var _div  =  $('.multiselect-location-container');
      var _l = Ladda.create(this);
      _l.start();
      if(!_div.is(':hidden') || (_div.is(':hidden') && _div.text().replace(/[\s\r\n]*/,'') == '') ||  _div.data('change')!="1" ) {
        $('.ajax-form').ajaxSubmit({
          beforeSubmit: function (arr, $form, options) {
            arr.push({ name: 'state', value: 'published' });
          },
          dataType: 'json',
          success: eventSuccess,
          error: eventError,
          complete: function () {
            _l.stop();
          }
        })
      }else{
        $('.event-form-container').slideUp();
        _div.slideDown();
        $("html, body").animate({ scrollTop: 0 }, "slow");
        _div.data('change', '0');
        _l.stop();
      }
    }

  }, ".event-save-and-publish");

  $(document).on({
    click: function(){
      $('#event_address').attr('value', $(this).data('address'))
    }
  }, "input[name='location_id']")
});

function eventError(response, status, xhr){
  $('.has-error').removeClass('has-error');
  $('.help-block').remove();
  if($('.event-form-container').is(':hidden')){
    $('.event-form-container').slideDown();
  }
  $.each(response.responseJSON, function(k,v){
    $("#event_"+k).closest(".form-group").addClass('has-error');
    $("#event_"+k).after("<span class='help-block'>"+v+"</span>");
  })
  $('.multiselect-location-container').slideUp();
}

function eventSuccess(response, status, xhr) {
  if (typeof(xhr.getResponseHeader('location')) != undefined){
    window.location = xhr.getResponseHeader('location');
  }
}


function locationError(response, status, xhr){
  $('.has-error').removeClass('has-error');
  $('.help-block').remove();
  $.each(response.responseJSON, function(k,v){
    if(k == 'location'){
      k='address';
    }
    $("#event_"+k).closest(".form-group").addClass('has-error');
    $("#event_"+k).after("<span class='help-block floatleft'>"+v+"</span>");
  })
}

function locationSuccess(response, status, xhr){
  if(xhr.status == 202){
    $('.multiselect-location-container').html("");
  }else if(xhr.status == 200){
    var _data = response;
   var _div = $('.multiselect-location-container');
    _div.html(
     HandlebarsTemplates['locations/show_radio'](
       {
          locations: _data.locations,
          location: _data.location
        }
     ));
    }
}

function locationAjax(){
  $.ajax({
    dataType: 'json',
    url: $("#prompt").attr('href'),
    data: {'venue[address]': $('#event_address').val() },
    type: 'POST',
    success: locationSuccess,
    error: locationError
  });
}


function addOrganization(){
  var _this = $('.add_organization');
  var _l = Ladda.create(_this[0]);
  _l.start();
  $.ajax({
    type: 'POST',
    url: _this.attr('href'),
    data: { organization: { name: $('#organizations_name').val() }}
  }).done(function(data, status, xhr){
    $('.help-block', _this.closest('.row')).html('');
    _this.closest('.row').removeClass('has-error');
    _div = $("<div>");
    _div.css('display','none');
    _div.load(xhr.getResponseHeader('Location'), function(){
      _o_id = $("[id^='event_organization_ids_']", _div).attr('id');
      if($("#"+_o_id).length == 0 ){
        _div.appendTo(".organization-container");
        _div.slideDown('slow', function(){
          _l.stop();
        });
      }else{
        _l.stop();
      }
      $('#organizations_name').val('');
    });

  }).error(function(data){
    str = "";
    $.each(data.responseJSON, function(key,val){
      str += val
    })
    $('.help-block', _this.closest('.row')).html(str);
    _this.closest('.row').addClass('has-error');
    _l.stop();
  })
}