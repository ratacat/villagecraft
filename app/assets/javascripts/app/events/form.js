$(function(){
  init_datetime_picker();
  $('#event_address').val($('option:selected',$(this)).data('address'));

  $('#event_venue_uuid').change(function(){
    $('#event_address').val($('option:selected',$(this)).data('address'));
    if($('option:selected',$(this)).data('address') == ''){
//      $('#new_venue_modal').modal('show');
      $("#event_venue_name").show();
      $(this).hide();
    }
  })

  $('#event_cost_type').change(function(){
    val = $('option:selected',$(this)).attr('value');
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
  })
  $("#event_rsvp").bootstrapSwitch({
    onInit: function(event, state){
      if($('#event_rsvp').is(':checked')){
        $('.yes').stop(true, true).slideDown();
      }else{
        $('.no').stop(true, true).slideDown();
      }
    }
  });
  $("#event_rsvp").on('switchChange.bootstrapSwitch', function(event, state) {
    if(state){
      $('.no').stop(true, true).slideUp();
      $('.yes').stop(true, true).slideDown();
    }else{
      $('.yes').stop(true, true).slideUp();
      $('#event_max_attendees').val('');
      $('.no').stop(true, true).slideDown();
    }
  });

  $(document).on({
    click: function(e){
      e.preventDefault();
      _this = $(this);
      var _l = Ladda.create(this);
      _l.start();
      $.ajax({
        type: 'POST',
        url: $(this).attr('href'),
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
  }, '.add_organization');


  $(document).on({
    click: function(e){
      e.preventDefault();
      $(this).closest('.row').slideUp(function(){
        $(this).remove();
      })
    }
  }, '.remove_organization');



  $(document).on('ajax:beforeSend', '#new_venue_modal form', function(event, xhr, settings) {
    if($('#location_id').length > 0) {
      settings.url = $("#prompt_save").attr('href');
    }
    xhr.setRequestHeader("Accept", "application/json");
  });

  $(document).on({
    click: function(){
      $(".choose").remove();
      $("#new_venue_modal form").trigger('reset');
      $('#new_venue_modal .form-inputs').show();
    }
  }, "#new_venue_modal .close" );

  $(document).on('ajax:success', '#new_venue_modal form', function(e, data, status, xhr) {
    if(xhr.status == 201){
      $("#new_venue_modal").modal('hide');
      $(".choose").remove();
      $('#new_venue_modal .form-inputs').show();
      $("#new_venue_modal form").trigger('reset');
      show_bootstrap_alert({text: "Your venue has been add.", type: 'success'});
      _option = $('<option value="'+data.uuid+'" data-address="'+data.address+'">'+data.name+'</option>');
      $('#event_venue_uuid').append(_option);
      $("#event_venue_uuid option").each(function(){
        if($(this).val()==data.uuid){
          $(this).attr('selected',true);
          $(this).trigger('change');
        }
      });
    }else if(xhr.status == 200){
      $(".choose").remove();
      _div = $('<div>');
      _div.addClass("choose");
      _div.html(
       HandlebarsTemplates['locations/show_radio'](
         {
            locations: data.locations,
            location: data.location
          }
       ));
      $('.remote_venue').prepend(_div);
      $('#new_venue_modal .form-inputs').hide();

    }
  });

  $(document).on({
    click: function(e){
      e.preventDefault();
      _this = $(this);
      var _l = Ladda.create(this);
      _l.start();
      $('.ajax-form').ajaxSubmit({
        success: eventSuccess,
        error: eventError,
        complete: function(){
          _l.stop();
        }
      })
    }

  }, ".ajax-form [type='submit'], .event-save");

  $(document).on({
    click: function(e){
      e.preventDefault();
      _this = $(this);
      var _l = Ladda.create(this);
      _l.start();
      $('.ajax-form').ajaxSubmit({
        beforeSubmit: function(arr, $form, options){
          arr.push({ name: 'state', value: 'published' });

        },
        success: eventSuccess,
        error: eventError,
        complete: function(){
          _l.stop();
        }
      })
    }

  }, ".event-save-and-publish");

});

function eventError(response, status, xhr){
  $('.has-error').removeClass('has-error');
  $('.help-block').remove();
  $.each(response.responseJSON, function(k,v){
    $("#event_"+k).closest(".form-group").addClass('has-error');
    $("#event_"+k).after("<span class='help-block'>"+v+"</span>");
  })
}

function eventSuccess(response, status, xhr) {
  if (typeof(xhr.getResponseHeader('location')) != undefined){
    console.log(xhr.getResponseHeader('location'));
//    window.location = xhr.getResponseHeader('location');
  }
}