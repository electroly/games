<Query Kind="Statements">
  <Namespace>System.Drawing</Namespace>
  <Namespace>System.Windows.Forms</Namespace>
  <Namespace>System.Drawing.Drawing2D</Namespace>
</Query>

var filePath = @"C:\Users\Brian Luft\Desktop\bee.png";

Bitmap bitmap = new(1500, 1500);
using (var originalBitmap = (Bitmap)Bitmap.FromFile(filePath))
{
	using var g = Graphics.FromImage(bitmap);
	for (var y = 0; y < 100; y++) {
		for (var x = 0; x < 100; x++) {
			var color = originalBitmap.GetPixel(x, y);
			using SolidBrush brush = new(color);
			g.FillRectangle(brush, new(x*15,y*15,15,15));
		}
	}
}

List<List<Point>> oldPolys = new();
List<Point> points = new();

Control panel = new() { Width = 1500, Height = 1500 };
panel.Paint += (_, e) => {
	e.Graphics.DrawImageUnscaled(bitmap, 0, 0);
	foreach (var poly in oldPolys) {
		for (var i = 1; i < poly.Count; i++) {
			var pt1 = poly[i - 1];
			var pt2 = poly[i];
			using Pen pen = new(Color.Black, 5);
			e.Graphics.DrawLine(pen, pt1.X * 15 + 7, pt1.Y * 15 + 7, pt2.X * 15 + 7, pt2.Y * 15 + 7);
		}
		foreach (var point in poly) {
			e.Graphics.FillRectangle(Brushes.Orange, new(point.X * 15, point.Y * 15, 15, 15));
		}
	}
			
	for (var i = 1; i < points.Count; i++) {
		var pt1 = points[i-1];
		var pt2 = points[i];
		using Pen pen = new(Color.DarkRed, 5);
		e.Graphics.DrawLine(pen, pt1.X*15+7, pt1.Y*15+7, pt2.X*15+7, pt2.Y*15+7);
	}
	foreach (var point in points) {
		e.Graphics.FillRectangle(Brushes.Red, new(point.X*15,point.Y*15,15,15));
	}
};
panel.MouseClick += (_, e) => {
	if (e.Button == MouseButtons.Right && points.Count > 0) {
		points.RemoveAt(points.Count - 1);
	} else if (e.X < 1500 && e.Y < 1500) {
		points.Add(new(100 * e.X / 1500, 100 * e.Y / 1500));
		if (points.Count > 1 && points[0].Equals(points[points.Count - 1]))
		{
			var str = string.Join(" ", points.Select(p => $"{p.X:00}{p.Y:00}"));
			Clipboard.SetText(str);
			MessageBox.Show("Copied:\r\n" + str);
			oldPolys.Add(points);
			points = new();
		}
	}
	panel.Refresh();
};
panel.Dump();
