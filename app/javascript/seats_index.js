// 現在時刻から「次の30分スロット」のDateオブジェクトを返す
// 例：14:10 → 14:30、14:45 → 15:00
function getNextHalfHour() {
  const now = new Date();
  if (now.getMinutes() < 30) {
    // 例：14:10 → 分を30に固定して 14:30 にする（秒・ミリ秒は0にリセット）
    now.setMinutes(30, 0, 0);
  } else {
    // 例：14:45 → 時を+1して 15:00 にする（分・秒・ミリ秒はすべて0にリセット）
    now.setHours(now.getHours() + 1, 0, 0, 0);
  }
  return now;   //// この時点での表示例 「Wed Jun 12 2024 14:30:00 GMT+0900」 (日本標準時)

}

// getNextHalfHour() の結果を "HH:mm" 形式の文字列にして返す
// Flatpickr の minTime には文字列が必要なため
// 例：{ hour: 9, min: 30 } → "09:30"
function getNextHalfHourString() {
  const d = getNextHalfHour();
  // getHours()で「時」、getMinutes()で「分」を取得
  // String()で数値を文字列に変換し、padStart(2, '0')で、この文字列が2文字未満なら、先頭に '0' を付けて2文字にしてください」という意味。1桁なら先頭に0を付ける
  // 例：9 → "09"、14 → "14"
  // テンプレートリテラル（`${}`）で "09:30" のような文字列を組み立てる
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

// 予約できる最大日付（今日から14日後）を返す
// 例：今日が6月1日なら、6月15日が最大選択日になる
function getMaxDate() {
  const maxDate = new Date();                      // 今日の日付を取得し、「maxDate」に格納
  maxDate.setDate(maxDate.getDate() + 14);         // 今日の日付を「getDate()」で取り出し、14を足す。そしてセットする。
  return maxDate;
}

// HTMLのDOMが読み込み完了してから実行する。このファイルを記述していてflatpickrを使用するページならどれでも、'turbo:load'（画面のロード）をイベント発火として使うことで、ページ遷移後も正しく動作する。
document.addEventListener('turbo:load', function () {

  // ── Flatpickr（日時選択カレンダー）の初期化 ──
  const dateInput = document.getElementById('date-input') || document.getElementById('reservation-date-input'); // 予約日時のinput要素
  if (dateInput) {  // 他のページでこのidが存在しない場合に備えてガード

    // URLの ?start_time= を取得する
    // 用途①: 間取り図ページで日時選択後にリロードされたとき → 選んでいた日時を復元する
    // 用途②: 予約フォームページを開いたとき → 間取り図で選んだ日時を自動入力する
    const urlParams = new URLSearchParams(window.location.search);
    const startTimeParam = urlParams.get('start_time');

    flatpickr(dateInput, {
      enableTime: true,               // 時刻も選択できるようにする
      dateFormat: "Y-m-d H:i〜",        // サーバーに送る表示形式（例：2026年5月17日 14:30〜）
      altInput: true,                 // 表示用の別inputを使う
      altFormat: "Y年m月d日 H:i〜",     // ユーザーに見せる形式
      locale: "ja",                   // カレンダーを日本語表示にする
      minDate: "today",               // 今日より前の日付は選択不可
      maxDate: getMaxDate(),          // 来週の土曜日まで選択可能
      defaultDate: startTimeParam ? startTimeParam.replace('〜', '') : getNextHalfHour(), // URLパラメーターがあればそれを初期値に、なければ次の30分スロットを初期値にする
      minTime: getNextHalfHourString(), // 今日の場合の選択可能な直近時刻の「HH:mm」形式
      time_24hr: true,                // 24時間表記（AM/PMではなく）
      minuteIncrement: 30,            // 分の選択を30分刻みにする
      
      // 日付や時刻を選んだときのイベントハンドラー(選択してカレンダーが閉じたときに呼ばれる「onClose」仕様。
      // 選択された日時をURLパラメーターに付けてページ再ロードするのは、間取り図ページで選んだ日時を反映させるため。
      // 予約フォームページでは、URLパラメーターがあればそれを初期値として使うので、選んだ日時がそのまま渡せる。)
      onClose: function (selectedDates, dateStr, instance) {
        if (selectedDates.length === 0) return;
        const selected = selectedDates[0];
        // 選んだ日付が今日かどうか判定
        const isToday = selected.toDateString() === new Date().toDateString();
        // 今日なら現在時刻以降のみ、明日以降なら00:00から選択可能にする
        instance.set('minTime', isToday ? getNextHalfHourString() : '00:00');

        // 間取り図ページの場合、選択した日時をURLパラメーターに付けてページ再ロード（その日時の座席情報を反映するため）
        if (document.querySelector('.floor-map-container')) {
          const url = new URL(window.location.href);  // URLオブジェクトを作成
          url.searchParams.set('start_time', dateStr);  // URLの ?start_time= に選んだ日時をセット（例：?start_time=2026-05-17%2014%3A30%EF%BD%9E）
          window.location.href = url.toString();  // URLを更新してページを再ロード
        }
      }
    });
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
