function toReservationForm() {
    const formButton = document.querySelector('.btn-booking');
    if (!formButton) return;

    formButton.addEventListener('click', function() {
        const seatNumber = document.querySelector('input[name="seat_id"]:checked').value;
        const storeId = formButton.getAttribute('data-store-id');

        window.location.href = `/stores/${storeId}/seats/${seatNumber}`;

});

};

window.addEventListener('turbo:load', toReservationForm);