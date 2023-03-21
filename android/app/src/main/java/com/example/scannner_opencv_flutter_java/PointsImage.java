package com.example.scannner_opencv_flutter_java;

import android.graphics.Bitmap;

import org.opencv.android.Utils;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.RotatedRect;
import org.opencv.core.Scalar;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class PointsImage {
    private final Bitmap BOrigImg;
    private final Mat MOriginalImg;
    private final double width;
    private final double height;

    //Constructor de clase PointsImage
    //Se obtiene el Bitmap de la imagen así como su ancho y alto
    PointsImage(Bitmap BOrigImg){
        //Se obtiene los datos de la imagen
        this.BOrigImg=BOrigImg;
        //Se obtiene el ancho y alto de la imagen
        this.width=BOrigImg.getWidth();
        this.height=BOrigImg.getHeight();
        //Se pasa BitMap -> Matriz
        this.MOriginalImg=new Mat();
        Utils.bitmapToMat(BOrigImg,this.MOriginalImg);
    }

    //TODO:Pendiente afinar la clasificación de contornos con algun metodo
    //Methodo que clasifica los contornos obtenidos
    public Mat ClassiFyContounrs(List<MatOfPoint> contours,Mat MOriginalImg){
        //Se itera sobre la lista de contornos obtenidos
        for(MatOfPoint c : contours) {
            double AreaEachContour=Imgproc.contourArea(c);
            //Imprimir el area de cada contorno
            //System.out.println(AreaEachContour);
            double epsilon = 0.01 * Imgproc.arcLength(new MatOfPoint2f(c.toArray()), true);
            MatOfPoint2f corners2f = new MatOfPoint2f();
            //Se obtienen los vertices
            Imgproc.approxPolyDP(new MatOfPoint2f(c.toArray()), corners2f, epsilon, true);
            //Se imprimen los vertices obetenidos
            //System.out.println(corners2f.toList());
            //Si el numero de vertices es igual a 4 sabemos que se trata de un rectangulo
            MatOfPoint corners = new MatOfPoint(corners2f.toArray());
            //System.out.println("nContornos"+corners.height());
            //Si se tiene mas de 3 vertices muy seguramente es un cuadrado y si el area del elemento coincide con el del contoro mas grande
            if (corners.size().height >= 3 && AreaEachContour == Imgproc.contourArea(contours.get(0))) {
                //Linea azul sobre la imagen original
                Imgproc.drawContours(MOriginalImg, Arrays.asList(c), -1, new Scalar(0, 255, 255), 15);
                //Linea amarilla sobre la imagen original
                Imgproc.drawContours(MOriginalImg, Arrays.asList(corners), -1, new Scalar(0, 255, 0), 5);

                //Se pintan los vertices de interes
                for (Point point: corners.toArray()){
                    //System.out.println(point);
                    Imgproc.circle(MOriginalImg,point, 15,new Scalar(255,0,0),15);
                }
                //Imgproc.circle(MInImg,corners.toArray()[0], 25,new Scalar(255,0,0),15);
                //Imgproc.circle(MInImg,corners.toArray()[1], 25,new Scalar(255,0,0),15);
                //Imgproc.circle(MInImg,corners.toArray()[2], 25,new Scalar(255,0,0),15);
                //Imgproc.circle(MInImg,corners.toArray()[3], 25,new Scalar(255,0,0),15);
                //    break;
            }
        }
        return MOriginalImg;
    }
    //Se realiza el pintado de las esquinas
    public Mat PaintCorners(MatOfPoint corners,Mat MOriginalImg){
        //Linea amarilla sobre la imagen original
        Imgproc.drawContours(MOriginalImg, Arrays.asList(corners), -1, new Scalar(0, 255, 0), 10);
        //Se pintan los vertices de interes
        for (Point point: corners.toArray()){
            //Se pintan puntos sobre las esquinas
            Imgproc.circle(MOriginalImg,point, 15,new Scalar(255,0,0),15);
        }
        return MOriginalImg;
    }

    //Se realiza la busqueda de un cuadrado o rectangulo a partir de las esquinas obtenidas
    public MatOfPoint SearchSquare(MatOfPoint corners){

        /*MatOfPoint largestSquare = null;
        double largestArea = 0;
        MatOfPoint2f approxCurve = new MatOfPoint2f();
        MatOfPoint2f contour2f = new MatOfPoint2f(corners.toArray());
        double contourArea = Imgproc.contourArea(corners);
        if (contourArea > largestArea) {
            double maxCosine = 0;
            for (int i = 2; i < 5; i++) {
                double cosine = Math.abs(angle(approxCurve.toArray()[i % 4], approxCurve.toArray()[i - 2], approxCurve.toArray()[i - 1]));
                maxCosine = Math.max(maxCosine, cosine);
            }

            if (maxCosine < 0.3) {
                largestSquare = new MatOfPoint(approxCurve.toArray());
                largestArea = contourArea;
            }
        }

        return largestSquare;*/
        return corners;
    }

    private double angle(Point p1, Point p2, Point p0) {
        double dx1 = p1.x - p0.x;
        double dy1 = p1.y - p0.y;
        double dx2 = p2.x - p0.x;
        double dy2 = p2.y - p0.y;
        return (dx1 * dx2 + dy1 * dy2) / Math.sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
    }

    //Se obtienen las esquinas a partir del mejor contorno
    public MatOfPoint RefineContours(List<MatOfPoint> listcontours){
        MatOfPoint Corners=new MatOfPoint();
        for(MatOfPoint contourn: listcontours){
            //Area del contorno
            double AreaEachContour=Imgproc.contourArea(contourn);
            double epsilon = 0.01 * Imgproc.arcLength(new MatOfPoint2f(contourn.toArray()), true);
            MatOfPoint2f corners2f = new MatOfPoint2f();
            //Se obtienen los vertices
            Imgproc.approxPolyDP(new MatOfPoint2f(contourn.toArray()), corners2f, epsilon, true);
            //Si el numero de vertices es igual a 4 sabemos que se trata de un rectangulo
            MatOfPoint corners = new MatOfPoint(corners2f.toArray());
            //Si se tiene mas de 3 vertices muy seguramente es un cuadrado y si el area del elemento coincide con el del contoro mas grande
                if (corners.size().height >= 3 && AreaEachContour == Imgproc.contourArea(listcontours.get(0))) {
                    Corners=corners;
                 break;
                }
            }
        //Se retornan las esquinas  el que tiene mayor aproximación
        return Corners;
    }

    //Se obtiene el contorno mas grande el cual corresponde al primer contorno encontrado al estar ordenados de mayor a menor
    public MatOfPoint GetLargerContour(Mat MOriginalImg){
        return SearchContourns(MOriginalImg).get(0);
    }
    //Se buscan los contronos extenernos de acuerdo a los contornos obtenidos en el metodos canny retornando una lista de contornos y se ordenan de acuerdo a su tamaño
    //de mayor a menor
    public List<MatOfPoint> SearchContourns(Mat MOriginalImg){
        //Encontrar los contornos
        List<MatOfPoint> contours = new ArrayList<>();
        Mat hierarchy = new Mat();
        Imgproc.findContours(GetContour(MOriginalImg),contours,hierarchy,Imgproc.RETR_EXTERNAL,Imgproc.CHAIN_APPROX_SIMPLE);
        //Se ordenan los conrtornos de acuerdo a su tamaño
        Collections.sort(contours, (o1, o2) -> Double.compare(Imgproc.contourArea(o2), Imgproc.contourArea(o1)));
        return contours;
    }


    //Se obtienen los contornos externos mediante el metodo canny se requiere como parametro la imagen en escala de grises y se retorna una matriz con los contornos
    public Mat GetContour(Mat MOriginalImg){
        Mat canny= new Mat();
        Imgproc.Canny(MOriginalImg,canny,10,150);
        Mat dilateKer = Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, new Size(5, 5));
        Imgproc.dilate(canny, canny, dilateKer);
        return canny;
    }

    //Se obtiene Matriz de scala de grises de la imagen original
    public Mat GetMGrayImg(Mat MOriginalImg){
        Mat gray=new Mat();
        Imgproc.cvtColor(MOriginalImg,gray,Imgproc.COLOR_BGR2GRAY);
        return gray;
    }

    //Se obtiene Matriz de la de la Imagen original
    public Mat GetMOriginalImg(){
        return this.MOriginalImg;
    }

    //Metodo usado para convertir una matriz -> Bitmap -> array para su posterior envio a flutter
    public byte[] GetBytesImg(Mat MOutImg){
        //Bitmap de salida Matriz -> Bitmap
        Bitmap OutImg = Bitmap.createBitmap(MOutImg.cols(), MOutImg.rows(), Bitmap.Config.ARGB_8888);
        //Se conviert matriz a bitmap
        Utils.matToBitmap(MOutImg,OutImg);
        //!PREPARING BITMAP TO SEND IN BYTEARRAY ON FORMAT JPGE
        ByteArrayOutputStream stream=new ByteArrayOutputStream();
        OutImg.compress(Bitmap.CompressFormat.JPEG,100,stream);
        return stream.toByteArray();
    }

}
