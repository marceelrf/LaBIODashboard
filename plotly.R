df1 %>%
  plot_ly(x= ~year, y= ~cites,
          type = "scatter",
          mode = "lines+markers",
          text = ~paste("Year: ", year,"\n Cites:",cites),
          marker = list(color = "#800000",
                        size = 15
                        ),
          line = list(
            color = "#800000",
            size = 5
            )
          ) %>%
  layout(
    xaxis = list(
      title = "Year",
      dtick = 1,
      tick0 = 2015,
      tickmode = "linear"
    ),
    yaxis = list(
      title = "Cites",
      dtick = 20,
      tick0 = 0,
      tickmode = "linear"
    )
  )
