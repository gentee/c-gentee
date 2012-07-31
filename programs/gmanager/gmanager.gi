method vForm0 vForm0.mLoad <alias=vForm0_mLoad>( )   
{   
//	this->vForm.mCreateWin()
	ustr ustmp
	uint comp
	comp as this
	with comp
	{
		.AutoLang=1
		.Border=$fbrdDialog
		.Bottom=0
		.Caption=ustmp.fromutf8("Gentee Manager")
		.Enabled=1
		.FormStyle=$fsChild
		.Height=400
		.HelpTopic=ustmp.fromutf8("")
		.Hint=ustmp.fromutf8("")
		.HorzAlign=$alhLeft
		.IconName=ustmp.fromutf8("")
		.Left=0
		.Name="Form0"
		.Right=0
		.StartPos=$spScreenCenter
		.Style=""
		.Tag=0
		.Top=0
		.TopMost=0
		.VertAlign=$alvTop
		.Visible=1
		.Width=595
		.WindowState=$wsNormal
		.OnCreate.Set( this, Form0_appinit )

		uint comp
		comp as this.Tab0
		comp.Owner = this
		with comp
		{
			.AutoLang=1
			.Bottom=52
			.Enabled=1
			.Height=305
			.HelpTopic=ustmp.fromutf8("")
			.Hint=ustmp.fromutf8("")
			.HorzAlign=$alhLeftRight
			.Left=15
			.Name="Tab0"
			.Right=12
			.Style=""
			.TabOrder=0
			.Tag=0
			.Top=10
			.VertAlign=$alvTopBottom
			.Visible=1
			.Width=560

			uint comp
			comp as this.TabItem0
			comp.Owner = this.Tab0
			with comp
			{
				.AutoLang=1
				.Bottom=0
				.Caption=ustmp.fromutf8("Application")
				.Enabled=1
				.Height=276
				.HelpTopic=ustmp.fromutf8("")
				.Hint=ustmp.fromutf8("")
				.HorzAlign=$alhLeft
				.Left=4
				.Name="TabItem0"
				.Right=0
				.Style=""
				.Tag=0
				.Top=25
				.VertAlign=$alvTop
				.Visible=1
				.Width=552

				uint comp
				comp as this.Btn0
				comp.Owner = this.TabItem0
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.BtnStyle=$bsClassic
					.Caption=ustmp.fromutf8("Gentee IDE (Debugger)")
					.Checked=0
					.Enabled=1
					.Height=35
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=25
					.Name="Btn0"
					.Right=0
					.Style=""
					.TabOrder=0
					.Tag=0
					.Top=30
					.VertAlign=$alvTop
					.Visible=1
					.Width=225
					.OnClick.Set( this, Form0_runide )
				}
				comp as this.Btn1
				comp.Owner = this.TabItem0
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.BtnStyle=$bsClassic
					.Caption=ustmp.fromutf8("Gentee Studio")
					.Checked=0
					.Enabled=1
					.Height=35
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=25
					.Name="Btn1"
					.Right=0
					.Style=""
					.TabOrder=1
					.Tag=0
					.Top=80
					.VertAlign=$alvTop
					.Visible=1
					.Width=225
					.OnClick.Set( this, Form0_runstudio )
				}
				comp as this.Btn2
				comp.Owner = this.TabItem0
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.BtnStyle=$bsClassic
					.Caption=ustmp.fromutf8("VisEdit (Demo)")
					.Checked=0
					.Enabled=1
					.Height=35
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=25
					.Name="Btn2"
					.Right=0
					.Style=""
					.TabOrder=2
					.Tag=0
					.Top=180
					.VertAlign=$alvTop
					.Visible=1
					.Width=225
					.OnClick.Set( this, Form0_runvis )
				}
				comp as this.Panel0
				comp.Owner = this.TabItem0
				with comp
				{
					.AutoLang=1
					.Border=$brdGroupBox
					.Bottom=0
					.Caption=ustmp.fromutf8("Documentation")
					.Enabled=1
					.Height=160
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=290
					.Name="Panel0"
					.Right=0
					.Style=""
					.TabOrder=3
					.Tag=0
					.Top=20
					.VertAlign=$alvTop
					.Visible=1
					.Width=250

					uint comp
					comp as this.Btn5
					comp.Owner = this.Panel0
					with comp
					{
						.AutoLang=1
						.Bottom=0
						.BtnStyle=$bsClassic
						.Caption=ustmp.fromutf8("Help v2.5")
						.Checked=0
						.Enabled=1
						.Height=35
						.HelpTopic=ustmp.fromutf8("")
						.Hint=ustmp.fromutf8("")
						.HorzAlign=$alhLeft
						.Left=20
						.Name="Btn5"
						.Right=0
						.Style=""
						.TabOrder=0
						.Tag=0
						.Top=95
						.VertAlign=$alvTop
						.Visible=1
						.Width=205
						.OnClick.Set( this, Form0_openchm25 )
					}
					comp as this.Btn3
					comp.Owner = this.Panel0
					with comp
					{
						.AutoLang=1
						.Bottom=0
						.BtnStyle=$bsClassic
						.Caption=ustmp.fromutf8("Help v3")
						.Checked=0
						.Enabled=1
						.Height=35
						.HelpTopic=ustmp.fromutf8("")
						.Hint=ustmp.fromutf8("")
						.HorzAlign=$alhLeft
						.Left=20
						.Name="Btn3"
						.Right=0
						.Style=""
						.TabOrder=1
						.Tag=0
						.Top=35
						.VertAlign=$alvTop
						.Visible=1
						.Width=205
						.OnClick.Set( this, Form0_openchm3 )
					}
				}
				comp as this.Btn8
				comp.Owner = this.TabItem0
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.BtnStyle=$bsClassic
					.Caption=ustmp.fromutf8("GeViewer")
					.Checked=0
					.Enabled=1
					.Height=35
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=25
					.Name="Btn8"
					.Right=0
					.Style=""
					.TabOrder=4
					.Tag=0
					.Top=130
					.VertAlign=$alvTop
					.Visible=1
					.Width=225
					.OnClick.Set( this, Form0_runviewer )
				}
			}
			comp as this.TabItem1
			comp.Owner = this.Tab0
			with comp
			{
				.AutoLang=1
				.Bottom=0
				.Caption=ustmp.fromutf8("Associate Ext.")
				.Enabled=1
				.Height=276
				.HelpTopic=ustmp.fromutf8("")
				.Hint=ustmp.fromutf8("")
				.HorzAlign=$alhLeft
				.Left=4
				.Name="TabItem1"
				.Right=0
				.Style=""
				.Tag=0
				.Top=25
				.VertAlign=$alvTop
				.Visible=0
				.Width=552

				uint comp
				comp as this.Label0
				comp.Owner = this.TabItem1
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.Caption=ustmp.fromutf8("Current Gentee compiler:")
					.Enabled=1
					.Height=25
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=20
					.Name="Label0"
					.Right=0
					.Style=""
					.Tag=0
					.TextHorzAlign=$talhLeft
					.TextVertAlign=$talvTop
					.Top=20
					.VertAlign=$alvTop
					.Visible=1
					.Width=680
					.WordWrap=0
					.AutoSize=0
				}
				comp as this.vRegcur
				comp.Owner = this.TabItem1
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.Enabled=0
					.Height=30
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=20
					.MaxLen=32768
					.Multiline=0
					.Name="vRegcur"
					.Password=0
					.ReadOnly=0
					.Right=0
					.ScrollBars=$sbNone
					.Style=""
					.TabOrder=1
					.Tag=0
					.Text=ustmp.fromutf8("")
					.Top=45
					.VertAlign=$alvTop
					.Visible=1
					.Width=480
					.WordWrap=0
					.Border=1
				}
				comp as this.vRegnew
				comp.Owner = this.TabItem1
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.Enabled=1
					.Height=30
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=20
					.MaxLen=32768
					.Multiline=0
					.Name="vRegnew"
					.Password=0
					.ReadOnly=0
					.Right=0
					.ScrollBars=$sbNone
					.Style=""
					.TabOrder=2
					.Tag=0
					.Text=ustmp.fromutf8("")
					.Top=95
					.VertAlign=$alvTop
					.Visible=1
					.Width=480
					.WordWrap=0
					.Border=1
				}
				comp as this.Btn6
				comp.Owner = this.TabItem1
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.BtnStyle=$bsClassic
					.Caption=ustmp.fromutf8("Change .G command line")
					.Checked=0
					.Enabled=1
					.Height=30
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=20
					.Name="Btn6"
					.Right=0
					.Style=""
					.TabOrder=3
					.Tag=0
					.Top=145
					.VertAlign=$alvTop
					.Visible=1
					.Width=225
					.OnClick.Set( this, Form0_changegline )
				}
				comp as this.Btn7
				comp.Owner = this.TabItem1
				with comp
				{
					.AutoLang=1
					.Bottom=0
					.BtnStyle=$bsClassic
					.Caption=ustmp.fromutf8("Set default command line")
					.Checked=0
					.Enabled=1
					.Height=35
					.HelpTopic=ustmp.fromutf8("")
					.Hint=ustmp.fromutf8("")
					.HorzAlign=$alhLeft
					.Left=20
					.Name="Btn7"
					.Right=0
					.Style=""
					.TabOrder=4
					.Tag=0
					.Top=210
					.VertAlign=$alvTop
					.Visible=1
					.Width=225
					.OnClick.Set( this, Form0_setdefault )
				}
			}
			.CurIndex=0
		}
		comp as this.Btn4
		comp.Owner = this
		with comp
		{
			.AutoLang=1
			.Bottom=0
			.BtnStyle=$bsClassic
			.Caption=ustmp.fromutf8("Exit")
			.Checked=0
			.Enabled=1
			.Height=30
			.HelpTopic=ustmp.fromutf8("")
			.Hint=ustmp.fromutf8("")
			.HorzAlign=$alhLeft
			.Left=225
			.Name="Btn4"
			.Right=0
			.Style=""
			.TabOrder=1
			.Tag=0
			.Top=325
			.VertAlign=$alvTop
			.Visible=1
			.Width=130
			.OnClick.Set( this, Form0_exit )
		}
	}

	return this
}

method vForm0 vForm0.init( )
{
   this.pTypeId = vForm0         
   return this
}
func init_vForm0 <entry>()
{   

   regcomp( vForm0, "vForm0", vForm, $vForm_last,
      %{ %{$mLoad,     vForm0_mLoad}},
      0->collection )
      
}
