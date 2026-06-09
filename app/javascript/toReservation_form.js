function toReservationForm() {
    const formButton = document.querySelector('.btn-booking');
    if (!formButton) return;

    formButton.addEventListener('click', function() {
        const seatNumber = document.querySelector('input[name="seat_id"]:checked').value;
        const startTime = document.getElementById('date-input').value; // 例: "2026-05-17 14:30〜"
        const storeId = formButton.getAttribute('data-store-id');

        const url = `/stores/${storeId}/seats/${seatNumber}/reservations/new`;
        window.location.href = startTime ? `${url}?start_time=${encodeURIComponent(startTime)}` : url;


});

};

window.addEventListener('turbo:load', toReservationForm);