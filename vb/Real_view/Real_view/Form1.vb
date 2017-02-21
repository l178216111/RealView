
Imports System.Threading
Public Class Realview
    Dim t As Thread
    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Me.Hide()
        Control.CheckForIllegalCrossThreadCalls = False
        t = New Thread(AddressOf screen_shot)
        t.Start()
    End Sub
    Private Sub Main_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed
        Try
            t.Abort()
        Catch
        End Try
    End Sub
    Public Sub screen_shot()
        Dim path As String = "c:\"
        Dim platform(3) As String
        platform(0) = "J750"
        platform(1) = "MST"
        platform(2) = "FLEX"
        platform(3) = "LTK"
        For i As Integer = 0 To platform.Length - 1
            Dim find = InStr(System.Environment.MachineName, platform(i))
            If find <> 0 Then
                If i = 0 Then
                    path = "z:\RealView\J750\"
                ElseIf i = 1 Then
                    path = "z:\RealView\MST\"
                ElseIf i = 2 Then
                    path = "z:\RealView\FLEX\"
                ElseIf i = 3 Then
                    path = "z:\RealView\LTK\"
                End If
            End If
        Next
        Dim p1 As New Point(0, 0)
        Dim p2 As New Point(Windows.Forms.Screen.PrimaryScreen.Bounds.Width, Windows.Forms.Screen.PrimaryScreen.Bounds.Height)
        Dim pic As New Bitmap(p2.X, p2.Y)
        While 1
            Application.DoEvents()
            System.Threading.Thread.Sleep(120000)
            Using g As Graphics = Graphics.FromImage(pic)
                g.CopyFromScreen(p1, p1, p2)
                Try
                    pic.Save(path & System.Environment.MachineName.ToUpper & ".jpg")
                Catch ex As Exception
                End Try
            End Using
        End While
    End Sub
End Class
