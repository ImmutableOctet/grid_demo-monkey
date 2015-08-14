Strict

Public

' Preprocessor related:
#GLFW_WINDOW_TITLE="Grid Demo"
#GLFW_WINDOW_WIDTH=1280
#GLFW_WINDOW_HEIGHT=720
#GLFW_WINDOW_SAMPLES=4
#GLFW_WINDOW_RESIZABLE=True
#GLFW_WINDOW_DECORATED=True
#GLFW_WINDOW_FLOATING=False
#GLFW_WINDOW_FULLSCREEN=False

' Imports:
Import mojo2

' Classes:
Class Application Extends App Final
	' Constant variable(s):
	Const Default_GridSize:Float = 64.0
	Const Default_Scale:Float = 0.5 ' 1.0
	
	' Functions:
	Function DrawTest:Void(Graphics:Canvas, Specialized:Bool=True, Unit:Float=11.3, Width:Int=90.0, Height:Int=90.0)
		If (Specialized) Then
			Graphics.Clear()
		Endif
		
		For Local Y:= 0 Until Height
			For Local X:= 0 Until Width
				Graphics.SetColor(Sin((X*Y) * 4.0) * 0.8, (1.0-Cos(X*Y)) * 0.8, Cos((Y+1) / (X+1)) * 0.5)
				
				Graphics.DrawRect(X*Unit, Y*Unit, Unit, Unit)
			Next
		Next
		
		If (Specialized) Then
			Graphics.Flush()
		Endif
		
		Return
	End
	
	Function FixProjection:Void(Graphics:Canvas)
		Graphics.SetProjection2d(0, DeviceWidth(), 0, DeviceHeight())
		
		Return
	End
	
	Function DrawGrid:Void(Graphics:Canvas, TileWidth:Int, TileHeight:Int, ScreenWidth:Int, ScreenHeight:Int)
		' Local variable(s):
		Local Matrix:Float[6]
		
		Graphics.GetMatrix(Matrix)
		
		DrawGrid(Graphics, TileWidth, TileHeight, ScreenWidth, ScreenHeight, Matrix)
		
		Return
	End
	
	Function DrawGrid:Void(Graphics:Canvas, TileWidth:Int, TileHeight:Int, ScreenWidth:Int, ScreenHeight:Int, Matrix:Float[], MOffset:Int=0)
		' Local variable(s):
		Local det:Float = ((Matrix[MOffset] * Matrix[MOffset+3]) - (Matrix[MOffset+2] * Matrix[MOffset+1]))
		
		Local a:Float = (Matrix[MOffset+3] / det)
		Local b:Float = (-Matrix[MOffset+1] / det)
		Local c:Float = (-Matrix[MOffset+2] / det)
		Local d:Float = (Matrix[MOffset] / det)
		
		Local tx:Float = (((Matrix[MOffset+2] * Matrix[MOffset+5]) - (Matrix[MOffset+3] * Matrix[MOffset+4])) / det)
		Local ty:Float = (((Matrix[MOffset+1] * Matrix[MOffset+4]) - (Matrix[MOffset] * Matrix[MOffset+5])) / det)
		
		Graphics.PushMatrix()
		
		Local OffsetX:Float = (-tx Mod TileWidth)
		Local OffsetY:Float = (-ty Mod TileHeight)
		
		Local W:= ((a * ScreenWidth) + (c * ScreenHeight)) + (TileWidth+OffsetX)
		Local H:= ((b * ScreenWidth) + (d * ScreenHeight)) + (TileHeight+OffsetY)
		
		Local LW:= (1 + ((W-1) / TileWidth))
		Local LH:= (1 + ((H-1) / TileHeight))
		
		Graphics.Translate(tx, ty)
		
		For Local Y:= 0 Until LH
			Local PY:= (Y*TileHeight) + OffsetY
			
			Graphics.DrawLine(0.0, PY, W-OffsetX, PY)
		Next
		
		For Local X:= 0 Until LW
			Local PX:= (X*TileWidth) + OffsetX
			
			Graphics.DrawLine(PX, 0.0, PX, H-OffsetY)
		Next
		
		Graphics.PopMatrix()
		
		Return
	End
	
	' Constructor(s):
	Method OnCreate:Int()
		Graphics = New Canvas()
		
		TestImage = New Image(1024, 1024)
		TestCanvas = New Canvas(TestImage)
		
		DrawTest(TestCanvas)
		
		GridSize = Default_GridSize
		Scale = Default_Scale
		
		' Return the default response.
		Return 0
	End
	
	' Methods:
	Method OnUpdate:Int()
		' Constant variable(s):
		Const UpScalar:Float = 0.995
		Const DownScalar:Float = (1.0 / UpScalar)
		
		If (KeyHit(KEY_F1)) Then
			GridSize = Default_GridSize
			Scale = Default_Scale
			
			X = 0.0; Y = 0.0
			
			Return 0
		Else
			If (KeyDown(KEY_O)) Then
				GridSize *= DownScalar
			Endif
			
			If (KeyDown(KEY_P)) Then
				GridSize *= UpScalar
			Endif
		Endif
		
		If (KeyDown(KEY_S) Or KeyDown(KEY_SPACE)) Then
			Scale *= UpScalar
		Endif
		
		If (KeyDown(KEY_W) Or KeyDown(KEY_F)) Then
			Scale *= DownScalar
		Endif
		
		Local Speed:Float = 2.25 * (1.0/Scale)
		
		If (KeyDown(KEY_UP)) Then
			Y -= Speed
		Endif
		
		If (KeyDown(KEY_DOWN)) Then
			Y += Speed
		Endif
		
		If (KeyDown(KEY_LEFT) Or KeyDown(KEY_A) Or KeyDown(KEY_Q)) Then
			X -= Speed
		Endif
		
		If (KeyDown(KEY_RIGHT) Or KeyDown(KEY_D) Or KeyDown(KEY_E)) Then
			X += Speed
		Endif
		
		Local NMX:= MouseX()
		Local NMY:= MouseY()
		
		If (MouseDown(MOUSE_LEFT)) Then ' Or TouchDown(0)
			X -= ((NMX-MX) * 2)
			Y -= ((NMY-MY) * 4)
		Endif
		
		If (MouseDown(MOUSE_RIGHT)) Then
			Local ScaleUnit:= (GridSize*4)
			
			Scale *= (1.0-((NMX-MX) / ScaleUnit))
			'Scale *= (1.0-((NMY-MY) / ScaleUnit))
		Endif
		
		MX = NMX
		MY = NMY
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		' Local variable(s):
		Local DW:= DeviceWidth()
		Local DH:= DeviceHeight()
		
		Graphics.SetViewport(0, 0, DW, DH)
		
		'FixProjection(Graphics)
		
		Graphics.Clear()
		
		Graphics.PushMatrix()
		
		Graphics.Translate(DW/2, DH/2)
		Graphics.Scale(Scale, Scale)
		Graphics.Translate(-X, -Y)
		
		DrawGrid(Graphics, GridSize, GridSize, DW, DH)
		
		'Graphics.Translate(-((Width*Unit)/2.0), -((Height*Unit)/2.0))
		
		Graphics.DrawImage(TestImage)
		'DrawTest(Graphics)
		
		Graphics.SetColor(1.0, 1.0, 1.0)
		
		Graphics.PopMatrix()
		
		Graphics.SetColor(0.75, 1.0, 0.25)
		Graphics.DrawText("Position: " + String(X) + ", " + String(Y), 16.0, 16.0)
		Graphics.DrawText("Scale: " + String(Int(Scale*100.0)) + "%", 16.0, 32.0)
		Graphics.SetColor(1.0, 1.0, 1.0)
		
		Graphics.Flush()
		
		' Return the default response.
		Return 0
	End
	
	Method OnResize:Int()
		FixProjection(Graphics)
		
		' Return the default response.
		Return 0
	End
	
	' Fields:
	Field Graphics:Canvas
	Field TestCanvas:Canvas
	
	Field TestImage:Image
	
	Field X:Float, Y:Float
	Field Scale:Float
	
	Field MX:Float, MY:Float
	Field GridSize:Float
End

' Functions:
Function Main:Int()
	New Application()
	
	' Return the default response.
	Return 0
End