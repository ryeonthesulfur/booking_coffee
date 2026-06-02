function confirmSeat() {
    const selectedSeat = document.getElementById('confirmed-seat');
    if (!selectedSeat) return;

    const seatNumber = selectedSeat.dataset.seatNumber;

    const radios = document.querySelectorAll('input[name="seat_id"]');
    radios.forEach(function(radio) {
        radio.disabled = true; // すべてのラジオボタンを一旦無効化

        if (radio.value === seatNumber) {
            radio.checked = true; // 該当する座席を選択状態にする
        }
    });

}



window.addEventListener('turbo:load', confirmSeat);