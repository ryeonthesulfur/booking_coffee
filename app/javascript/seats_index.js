// 現在時刻から「次の30分スロット」のDateオブジェクトを返す
// 例：14:10 → 14:30、14:45 → 15:00
function getNextHalfHour() {
  const now = new Date();
  if (now.getMinutes() < 30) {
    now.setMinutes(30, 0, 0);   // 分・秒・ミリ秒をセット
  } else {
    now.setHours(now.getHours() + 1, 0, 0, 0); // 時・分・秒・ミリ秒をセット
  }
  return now;
}

// getNextHalfHour() の結果を "HH:mm" 形式の文字列にして返す
// Flatpickr の minTime には文字列が必要なため
// 例：{ hour: 9, min: 30 } → "09:30"
function getNextHalfHourString() {
  const d = getNextHalfHour();
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  // padStart(2, '0')：1桁の数字を "9" → "09" のようにゼロ埋めする
}

// 予約できる最大日付（今日から14日後）を返す
function getMaxDate() {
  const maxDate = new Date();
  maxDate.setDate(maxDate.getDate() + 14);
  return maxDate;
}

// HTMLのDOMが読み込み完了してから実行する
document.addEventListener('turbo:load', function () {

  // ── Flatpickr（日時選択カレンダー）の初期化 ──
  const dateInput = document.getElementById('date-input') || document.getElementById('reservation-date-input'); // 予約日時のinput要素
  if (dateInput) {  // 他のページでこのidが存在しない場合に備えてガード
    flatpickr(dateInput, {
      enableTime: true,               // 時刻も選択できるようにする
      dateFormat: "Y年m月d日 H:i〜",  // 表示形式（例：2026年5月17日 14:30〜）
      locale: "ja",                   // カレンダーを日本語表示にする
      minDate: "today",               // 今日より前の日付は選択不可
      maxDate: getMaxDate(),          // 来週の土曜日まで選択可能
      defaultDate: getNextHalfHour(), // 初期表示を「次の30分スロット」にする
      minTime: getNextHalfHourString(), // 今日の場合の選択可能な最小時刻
      time_24hr: true,                // 24時間表記（AM/PMではなく）
      minuteIncrement: 30,            // 分の選択を30分刻みにする
      onChange: function (selectedDates, dateStr, instance) {
        if (selectedDates.length === 0) return;
        const selected = selectedDates[0];
        // 選んだ日付が今日かどうか判定
        const isToday = selected.toDateString() === new Date().toDateString();
        // 今日なら現在時刻以降のみ、明日以降なら00:00から選択可能にする
        instance.set('minTime', isToday ? getNextHalfHourString() : '00:00');
      }
    });
  }

  // ── カルーセル ──
  const track = document.getElementById('carousel-track');
  if (track) {
    const btnLeft = document.getElementById('carousel-btn-left');
    const btnRight = document.getElementById('carousel-btn-right');
    const cards = track.querySelectorAll('.seat-card');
    const visibleCount = 3;
    let currentIndex = 0;

    function updateCarousel() {
      const gap = 24; // 1.5rem
      const cardWidth = cards[0].offsetWidth;
      track.style.transform = `translateX(-${currentIndex * (cardWidth + gap)}px)`;
      btnLeft.disabled = currentIndex === 0;
      btnRight.disabled = currentIndex >= cards.length - visibleCount;
    }

    btnRight.addEventListener('click', () => {
      if (currentIndex < cards.length - visibleCount) {
        currentIndex++;
        updateCarousel();
      }
    });

    btnLeft.addEventListener('click', () => {
      if (currentIndex > 0) {
        currentIndex--;
        updateCarousel();
      }
    });

    updateCarousel();
  }

  // ── カテゴリフィルターボタンの切り替え ──
  const filterContainer = document.getElementById('filter-buttons');
  if (!filterContainer) return;

  const filterBtns = filterContainer.querySelectorAll('.filter-btn');

  filterContainer.addEventListener('click', (event) => {
    // クリックされた要素が .filter-btn かどうか確認（子要素クリックにも対応）
    const clicked = event.target.closest('.filter-btn');
    if (!clicked) return;

    // いったんすべてのボタンからアクティブクラスを外す
    filterBtns.forEach(btn => btn.classList.remove('filter-btn--active'));
    // クリックされたボタンだけアクティブにする
    clicked.classList.add('filter-btn--active');

    const selected = clicked.dataset.category;
    console.log('選択されたカテゴリ:', selected);
  });
});
