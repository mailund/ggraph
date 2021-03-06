#' Draw edges as curves of different curvature
#'
#' This geom draws edges as cubic beziers with the control point positioned
#' half-way between the nodes and at an angle dependent on the presence of
#' parallel edges. This results in parallel edges being drawn in a
#' non-overlapping fashion resembling the standard approach used in
#' [igraph::plot.igraph()]. Before calculating the curvature the edges
#' are sorted by direction so that edges going the same way will be adjacent.
#' This geom is currently the only choice for non-simple graphs if edges should
#' not be overplotted.
#'
#' @inheritSection geom_edge_link Edge variants
#' @inheritSection geom_edge_link Edge aesthetic name expansion
#'
#' @section Aesthetics:
#' `geom_edge_fan` and `geom_edge_fan0` understand the following
#' aesthetics. Bold aesthetics are automatically set, but can be overridden.
#'
#' - **x**
#' - **y**
#' - **xend**
#' - **yend**
#' - **from**
#' - **to**
#' - edge_colour
#' - edge_width
#' - edge_linetype
#' - edge_alpha
#' - filter
#'
#' `geom_edge_fan2` understand the following aesthetics. Bold aesthetics are
#' automatically set, but can be overridden.
#'
#' - **x**
#' - **y**
#' - **group**
#' - **from**
#' - **to**
#' - edge_colour
#' - edge_width
#' - edge_linetype
#' - edge_alpha
#' - filter
#'
#' `geom_edge_fan` and `geom_edge_fan2` furthermore takes the following
#' aesthetics.
#'
#' - start_cap
#' - end_cap
#' - label
#' - label_pos
#' - label_size
#' - angle
#' - hjust
#' - vjust
#' - family
#' - fontface
#' - lineheight
#'
#' @section Computed variables:
#'
#' \describe{
#'  \item{index}{The position along the path (not computed for the *0 version)}
#' }
#'
#' @inheritParams geom_edge_link
#' @inheritParams ggplot2::geom_path
#'
#' @param spread Modify the width of the fans `spread > 1` will create
#' wider fans while the reverse will make them more narrow.
#'
#' @author Thomas Lin Pedersen
#'
#' @family geom_edge_*
#'
#' @examples
#' require(tidygraph)
#' gr <- as_tbl_graph(data.frame(
#'   from = c(1, 1, 1, 1, 1, 2, 2, 2),
#'   to = c(2, 2, 2, 2, 2, 1, 1, 1),
#'   class = sample(letters[1:3], 8, TRUE)
#' )) %>%
#'   mutate(class = c('a', 'b'))
#'
#' ggraph(gr, 'nicely') +
#'   geom_edge_fan(aes(alpha = ..index..))
#'
#' ggraph(gr, 'nicely') +
#'   geom_edge_fan2(aes(colour = node.class))
#'
#' ggraph(gr, 'nicely') +
#'   geom_edge_fan0(aes(colour = class))
#'
#' @rdname geom_edge_fan
#' @name geom_edge_fan
#'
NULL

#' @rdname ggraph-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggforce StatBezier
#' @export
StatEdgeFan <- ggproto('StatEdgeFan', StatBezier,
    setup_data = function(data, params) {
        if (any(names(data) == 'filter')) {
            if (!is.logical(data$filter)) {
                stop('filter must be logical')
            }
            data <- data[data$filter, names(data) != 'filter']
        }
        data$group <- seq_len(nrow(data))
        data2 <- data
        data2$x <- data2$xend
        data2$y <- data2$yend
        data$xend <- NULL
        data$yend <- NULL
        data2$xend <- NULL
        data2$yend <- NULL
        createFans(data, data2, params)
    },
    required_aes = c('x', 'y', 'xend', 'yend', 'from', 'to'),
    default_aes = aes(filter = TRUE),
    extra_params = c('na.rm', 'n', 'spread')
)
#' @rdname geom_edge_fan
#'
#' @export
geom_edge_fan <- function(mapping = NULL, data = get_edges(),
                          position = "identity", arrow = NULL,
                          spread = 1, n = 100, lineend = "butt",
                          linejoin = "round", linemitre = 1,
                          label_colour = 'black',  label_alpha = 1,
                          label_parse = FALSE, check_overlap = FALSE,
                          angle_calc = 'rot', force_flip = TRUE,
                          label_dodge = NULL, label_push = NULL,
                          show.legend = NA, ...) {
    mapping <- completeEdgeAes(mapping)
    mapping <- aesIntersect(mapping, aes_(x=~x, y=~y, xend=~xend, yend=~yend,
                                          from=~from, to=~to))
    layer(data = data, mapping = mapping, stat = StatEdgeFan,
          geom = GeomEdgePath, position = position, show.legend = show.legend,
          inherit.aes = FALSE,
          params = expand_edge_aes(
              list(arrow = arrow, lineend = lineend, linejoin = linejoin,
                   linemitre = linemitre, na.rm = FALSE, n = n,
                   interpolate = FALSE, spread = spread,
                   label_colour = label_colour, label_alpha = label_alpha,
                   label_parse = label_parse, check_overlap = check_overlap,
                   angle_calc = angle_calc, force_flip = force_flip,
                   label_dodge = label_dodge, label_push = label_push, ...)
          )
    )
}
#' @rdname ggraph-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggforce StatBezier2
#' @export
StatEdgeFan2 <- ggproto('StatEdgeFan2', StatBezier2,
    setup_data = function(data, params) {
        if (any(names(data) == 'filter')) {
            if (!is.logical(data$filter)) {
                stop('filter must be logical')
            }
            data <- data[data$filter, names(data) != 'filter']
        }
        data <- data[order(data$group),]
        data2 <- data[c(FALSE, TRUE), ]
        data <- data[c(TRUE, FALSE), ]
        createFans(data, data2, params)
    },
    required_aes = c('x', 'y', 'group', 'from', 'to'),
    default_aes = aes(filter = TRUE),
    extra_params = c('na.rm', 'n', 'spread')
)
#' @rdname geom_edge_fan
#'
#' @export
geom_edge_fan2 <- function(mapping = NULL, data = get_edges('long'),
                           position = "identity", arrow = NULL,
                           spread = 1, n = 100, lineend = "butt",
                           linejoin = "round", linemitre = 1,
                           label_colour = 'black',  label_alpha = 1,
                           label_parse = FALSE, check_overlap = FALSE,
                           angle_calc = 'rot', force_flip = TRUE,
                           label_dodge = NULL, label_push = NULL,
                           show.legend = NA, ...) {
    mapping <- completeEdgeAes(mapping)
    mapping <- aesIntersect(mapping, aes_(x=~x, y=~y, group=~edge.id,
                                          from=~from, to=~to))
    layer(data = data, mapping = mapping, stat = StatEdgeFan2,
          geom = GeomEdgePath, position = position, show.legend = show.legend,
          inherit.aes = FALSE,
          params = expand_edge_aes(
              list(arrow = arrow, lineend = lineend, linejoin = linejoin,
                   linemitre = linemitre, na.rm = FALSE, n = n,
                   interpolate = TRUE, spread = spread,
                   label_colour = label_colour, label_alpha = label_alpha,
                   label_parse = label_parse, check_overlap = check_overlap,
                   angle_calc = angle_calc, force_flip = force_flip,
                   label_dodge = label_dodge, label_push = label_push, ...)
          )
    )
}
#' @rdname ggraph-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggforce StatBezier0
#' @export
StatEdgeFan0 <- ggproto('StatEdgeFan0', StatBezier0,
    setup_data = function(data, params) {
        StatEdgeFan$setup_data(data, params)
    },
    required_aes = c('x', 'y', 'xend', 'yend', 'from', 'to'),
    default_aes = aes(filter = TRUE),
    extra_params = c('na.rm', 'spread')
)
#' @rdname geom_edge_fan
#'
#' @export
geom_edge_fan0 <- function(mapping = NULL, data = get_edges(),
                                position = "identity", arrow = NULL, spread = 1,
                                lineend = "butt", show.legend = NA, ...) {
    mapping <- completeEdgeAes(mapping)
    mapping <- aesIntersect(mapping, aes_(x=~x, y=~y, xend=~xend, yend=~yend,
                                          from=~from, to=~to))
    layer(data = data, mapping = mapping, stat = StatEdgeFan0,
          geom = GeomEdgeBezier, position = position, show.legend = show.legend,
          inherit.aes = FALSE,
          params = expand_edge_aes(
              list(arrow = arrow, lineend = lineend, na.rm = FALSE,
                        spread = spread, ...)
          )
    )
}
#' @importFrom dplyr %>% group_by_ arrange_ mutate_ n ungroup transmute_
createFans <- function(from, to, params) {
    from$.id <- paste(pmin(from$from, to$to), pmax(from$from, to$to), sep = '-')
    from$.origInd <- seq_len(nrow(from))
    position <- from %>% group_by_(~PANEL, ~.id) %>%
        arrange_(~from) %>%
        mutate_(position = ~seq_len(n()) - 0.5 - n()/2) %>%
        mutate_(position = ~position * ifelse(from < to, 1, -1)) %>%
        ungroup() %>%
        arrange_(~.origInd) %>%
        transmute_(position = ~position)
    position <- position$position
    maxFans <- max(table(from$.id))
    from$.id <- NULL
    from$.origInd <- NULL
    meanX <- rowMeans(cbind(from$x, to$x))
    meanY <- rowMeans(cbind(from$y, to$y))
    stepX <- -(params$spread * (to$y - from$y) / (2*maxFans))
    stepY <- params$spread * (to$x - from$x) / (2*maxFans)
    data <- from
    data$x <- meanX + stepX*position
    data$y <- meanY + stepY*position
    bezierStart <- seq(1, by = 3, length.out = nrow(from))
    from$index <- bezierStart
    to$index <- bezierStart + 2
    data$index <- bezierStart + 1
    data <- rbind(from, data, to)
    data[order(data$index), names(data) != 'index']
}
