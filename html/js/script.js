let item = []

$('document').ready(function () {
  window.addEventListener('message', function (event) {
    var item = event.data;
    if (item.type == "open") {
      openBattlePass(item)
    }

    if (item.type == "levelup") {
      sendNotif(item.level, item.premium);
    }

    if (item.type == "close") {
      closeBattlePass()
    }
  })
})

$(document).keyup(function(e) {
  if (e.key === "Escape") { // escape key maps to keycode `27`
    closeBattlePass()
 }
});


let currentMin = null;
$(".prev-tier").click(function(){
  let active = $(".prev-tier").hasClass("not-active");
  if(!active){
    loadTiers(currentMin - 10, currentMin)
    currentMin = currentMin - 10
  }
})

$(".next-tier").click(function(){
  let active = $(".next-tier").hasClass("not-active");
  if(!active){
    loadTiers(currentMin + 10, currentMin + 20)
    currentMin = currentMin + 10
  }
})

function loadTiers(min, max){
  let data = item.data
  let config = item.config

  if(min == 1){
    $(".prev-tier").addClass("not-active");
  } else{
    $(".prev-tier").removeClass("not-active");
  }
  if(max == 51){
    $(".next-tier").addClass("not-active");
  } else {
    $(".next-tier").removeClass("not-active");
  }

  $(".tiers").html('<th class="pass">Level</th>')
  for(let i = min; i <= max; i++){
    $(".tiers").append(`<th>${i}</th>`)
  }
  $.each(config, function(i, val){
    if (i == "FreePassDetails"){
      $(".free-side").html('<td class="pass"><img src="https://static.wikia.nocookie.net/fortnite/images/6/6f/Free_Pass_-_Icon_-_Fortnite.png" width="150px"></td>')
      $.each(val, function(index, item){
        let jsMin = index + 1
        if (jsMin >= min && jsMin <= max){
          let imageStyle = (data.level <= index) ? "opacity:0.1;" : "";
          let divId = (data.level > index) ? 'id="battlepass-item-free"' : "";
          let html = `
          <td class="battlepass-item" ${divId} data-index="${index}">
            <img src="${item.url}" alt="Avatar" class="image" style="width:100%;${imageStyle}">
            <div class="middletext">
              <div class="text">${item.amount}x ${item.label}</div>
            </div>
          </td>
          `
          $(".free-side").append(html)
        }
      })
    } else if (i == "PremiumPassDetails"){
      $(".premium-side").html('<td class="pass"><img onclick="openTebex()" src="https://static.wikia.nocookie.net/fortnite/images/f/f0/Battle_Pass_-_Icon_-_Fortnite.png" width="150px"></td>')
      $.each(val, function(index, item){
        let jsMin = index + 1
        if (jsMin >= min && jsMin <= max){
          let imageStyle = (data.level <= index) ? "opacity:0.1;" : "";
          let divId = (data.level > index) ? 'id="battlepass-item-premium"' : "";
          let html = `
          <td class="battlepass-item" ${divId} data-index="${index}">
            <img src="${item.url}" alt="Avatar" class="image" style="width:100%;${imageStyle}">
            <div class="middletext">
              <div class="text">${item.amount}x ${item.label}</div>
            </div>
          </td>
          `
          $(".premium-side").append(html)
        }
      })
    }
  })
}

function sendNotif(level, premium){
  $("#newLevel").html(level)
  $(".notify-container").fadeIn(400).delay(5000).fadeOut(400);
  if (premium){
    $("#notifyImg").attr("src", "https://static.wikia.nocookie.net/fortnite/images/f/f0/Battle_Pass_-_Icon_-_Fortnite.png")
  } else {
    $("#notifyImg").attr("src", "https://static.wikia.nocookie.net/fortnite/images/6/6f/Free_Pass_-_Icon_-_Fortnite.png")
  }
}

function openTebex() {
	window.invokeNative('openUrl', 'https://store.trappin.gg/')
}


function openBattlePass(newitem){
  item = newitem;
  loadTiers(1, 10)
  currentMin = 1
  $(".level").html(item.data.level)
  $(".xp").html(item.data.xp + "xp")
  $(".xp-togo").html(item.nextxp - item.data.xp + " xp to go!")
  $(".xp-bar-inside").css({ 'width': (item.data.xp / item.nextxp * 100) + "%" });
  $(".container").css({ 'display': 'block' });
}
// $(".container").css({ 'display': 'block' });


function closeBattlePass(){
  $(".container").css({ 'display': 'none' });
  $.post('http://almez-battlepass/Close')
}

$('.free-side').on('click', '#battlepass-item-free', function(e) {
  let div = this
  e.preventDefault();
  Swal.fire({
    title: 'Are you sure?',
    text: "You won't be able to revert this!",
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#5c1cf4',
    cancelButtonColor: '#d33',
    confirmButtonText: 'Yes, give me the reward!'
  }).then((result) => {
    if (result.isConfirmed) {
      let index = Number($(div).attr('data-index'))
      $.post('http://almez-battlepass/GetPassReward', JSON.stringify({
        premium: false,
        index: index,
      }), function (data) {
        if (data) {
          Swal.fire(
            'Completed!',
            '',
            'success'
          )
        } else {
          Swal.fire(
            'Error!',
            'Something went wrong, contact the support.',
            'error'
          )
        }
      })
    }
  })
})

$('.premium-side').on('click', '#battlepass-item-premium', function(e) {
  let div = this
  e.preventDefault();
  Swal.fire({
    title: 'Are you sure?',
    text: "You won't be able to revert this!",
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#5c1cf4',
    cancelButtonColor: '#d33',
    confirmButtonText: 'Yes, give me the reward!'
  }).then((result) => {
    if (result.isConfirmed) {
      let index = Number($(div).attr('data-index'))
      $.post('http://almez-battlepass/GetPassReward', JSON.stringify({
        premium: true,
        index: index,
      }), function (data) {
        if (data) {
          Swal.fire(
            'Completed!',
            '',
            'success'
          )
        } else {
          Swal.fire(
            'Error!',
            'Something went wrong, contact the support.',
            'error'
          )
        }
      })
    }
  })
})

function makeTimer() {

  var endTime = new Date("31 March 2023 00:00:00 GMT-07:00");
  endTime = (Date.parse(endTime) / 1000);

  var now = new Date();
  now = (Date.parse(now) / 1000);

  var timeLeft = endTime - now;

  var days = Math.floor(timeLeft / 86400);
  var hours = Math.floor((timeLeft - (days * 86400)) / 3600);
  var minutes = Math.floor((timeLeft - (days * 86400) - (hours * 3600)) / 60);
  var seconds = Math.floor((timeLeft - (days * 86400) - (hours * 3600) - (minutes * 60)));

  if (hours < "10") { hours = "0" + hours; }
  if (minutes < "10") { minutes = "0" + minutes; }
  if (seconds < "10") { seconds = "0" + seconds; }

  $(".timer").html("NEXT SEASON: "+days+" days "+hours+" hours")
}
makeTimer()
setInterval(function () { makeTimer(); }, 1000);