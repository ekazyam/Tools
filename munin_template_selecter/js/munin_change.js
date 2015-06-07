$(document).ready(function()
{
	var MSG_ASK = "テンプレートを変更しますか？";
	var MSG_INFO = "テンプレートを更新しました。";
	var MSG_ERR = "更新に失敗しました。";

	function UpdateState()
	{
		var select_template = $("input[name='munin_radio']:checked").val();
		$.ajax({
			type: 'post',
			url: 'conf/aaa.php',
			data: { 
				'template_data': select_template
			},
			success: function(data){
				Notice();
			}
		});
                return false;
	}

	/* ラジオボタンが選択された際に動作する */
	$(document).ready(function () {
		$("input[name='munin_radio']").click(function () {
			/* 更新確認 */
                	alertify.confirm( MSG_ASK , function (e) {
                		if (e) {
					/* 更新処理 */
					UpdateState();
				}
			});
		});
	});

	/* 更新通知を行う */
	function Notice()
	{
		 alertify.success( MSG_INFO );
	}

	function NoticeErr()
	{
		 alertify.success( MSG_ERR );
	}
});
