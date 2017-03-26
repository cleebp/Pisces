public static class TimeUtil
{
  public static double systemSeconds()
  {
    return System.nanoTime() / 1000000000.d;
  }  
}  