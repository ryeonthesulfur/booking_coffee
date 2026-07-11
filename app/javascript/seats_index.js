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
  return now;
}

// getNextHalfHour() の結果を "HH:mm" 形式の文字列にして返す
// Flatpickr の minTime には文字列が必要なため
function getNextHalfHourString() {
  const d = getNextHalfHour();
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

// 予約できる最大日付（今日から14日後）を返す
function getMaxDate() {
  const maxDate = new Date();
  maxDate.setDate(maxDate.getDate() + 14);
  return maxDate;
}

// HTMLのDOMが読み込み完了してから実行する。このファイルを記述していてflatpickrを使用するページならどれでも、'turbo:load'（画面のロード）をイベント発火として使うことで、ページ遷移後も正しく動作する。
document.addEventListener('turbo:load', function () {
  const dateInput = document.getElementById('date-input') || document.getElementById('reservation-date-input');
  if (dateInput) {  // 他のページでこのidが存在しない場合に備えてガード
    // URLの ?start_time= を取得する
    // 用途①: 間取り図ページで日時選択後にリロードされたとき → 選んでいた日時を復元する
    // 用途②: 予約フォームページを開いたとき → 間取り図で選んだ日時を自動入力する
    const urlParams = new URLSearchParams(window.location.search);
    const startTimeParam = urlParams.get('start_time');

    let defaultDateVal;
    // URLの日時が未来なら使い、過去なら次の30分スロットを初期値にする
    if (startTimeParam) {
      const parsed = new Date(startTimeParam.replace('〜', ''));  // "2026-05-17 14:30〜" → "2026-05-17 14:30" にしてからDateオブジェクトに変換
      defaultDateVal = parsed > new Date() ? parsed : getNextHalfHour();
    } else {
      defaultDateVal = getNextHalfHour();
    }

    // 初期値が今日の日付かどうかを判定（今日なら現在時刻以降のみ選択可能にするため）
    const isDefaultToday = new Date(defaultDateVal).toDateString() === new Date().toDateString();
    flatpickr(dateInput, {
      enableTime: true,               
      dateFormat: "Y-m-d H:i〜",        // サーバーに送る表示形式（例：2026年5月17日 14:30〜）
      altInput: true,                 
      altFormat: "Y年m月d日 H:i〜",     // ユーザーに見せる形式
      locale: "ja",                   
      minDate: "today",               // 今日より前の日付は選択不可
      maxDate: getMaxDate(),          // 来週の土曜日まで選択可能
      defaultDate: defaultDateVal,    // URLパラメーターがあればそれを初期値に、なければ次の30分スロットを初期値にする
      minTime: isDefaultToday ? getNextHalfHourString() : '00:00', // 今日なら現在時刻以降のみ、翌日以降なら00:00から選択可能
      time_24hr: true,                // 24時間表記（AM/PMではなく）
      minuteIncrement: 30,            // 分の選択を30分刻みにする
      
      // 画面リロード時の時間選択範囲の判定だけでなく、カレンダーで日付を選択している最中でも同様の判定が機能するようにした。
      onChange: function (selectedDates, dateStr, instance) {
        if (selectedDates.length === 0) return;
        const selected = selectedDates[0];
        // 選んだ日付が今日かどうか判定
        const isToday = selected.toDateString() === new Date().toDateString();
        // 今日なら現在時刻以降のみ、明日以降なら00:00から選択可能にする
        instance.set('minTime', isToday ? getNextHalfHourString() : '00:00');
      },

      // カレンダーを閉じたときに間取り図ページをリロードする
      // 選択された日時をURLパラメーターに付けてページ再ロードするのは、間取り図ページで選んだ日時を反映させるため。
      onClose: function (selectedDates, dateStr, instance) {
        if (selectedDates.length === 0) return;
        // 間取り図のページでのみ、URLを更新してリロードする
        if (document.querySelector('.floor-map-container')) {
          const url = new URL(window.location.href);
          url.searchParams.set('start_time', dateStr);
          window.location.href = url.toString();
        }
      }
    });
  }
});
