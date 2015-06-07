$(document).ready(function()
{
	var MSG_ASK = "テンプレートを変更しますか？";
	var MSG_INFO = "テンプレートを更新しました。";
	var MSG_ERR = "更新に失敗しました。";

	$('#change').click(function()
	{
		if( Ask() )
		{
			/* 選択したラジオボタンを取得 */
			var select_template = $("input[name='munin_radio']:checked").val();
			$.post("./index.php",
				{
					"select": select_template
				},
				function(response)
				{
					Notice();
				}
			));
		}
		return false;
	});

	function Ask()
	{
               	alertify.confirm( MSG_ASK , function (e) {
			if(e)
			{
				return true;
			} else {
				return false;
			}
		});
	}

	function Notice()
	{
		 alertify.success( MSG_INFO );
	}

	function NoticeErr()
	{
		 alertify.success( MSG_ERR );
	}
});
