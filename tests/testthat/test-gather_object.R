context("gather_object")

test_that("works in a simple case", {

    json <- '{"name1": 1, "name2": 2}'

    expect_identical(
      json %>% gather_object,
      tbl_json(
        data.frame(
          document.id = c(1L, 1L),
          name = c("name1", "name2"),
          stringsAsFactors = FALSE
        ),
        list(1L, 2L)
      )
    )

  }
)

test_that("works with compound values", {

    json <- '{
		  "name1": 1,
      "name2": {"sub": "a"},
      "name3": [true, false],
      "name4": null
		}'

    expect_identical(
      json %>% gather_object,
      tbl_json(
        data.frame(
          document.id = c(1L, 1L, 1L, 1L),
          name = c("name1", "name2", "name3", "name4"),
          stringsAsFactors = FALSE
        ),
        list(1L, list(sub = "a"), list(TRUE, FALSE), NULL)
      )
    )

  }
)

test_that("throws errors with incorrect types", {

    expect_error('1' %>% gather_object(), "1 records are not objects")
    expect_error('["a"]' %>% gather_object(), "1 records are not objects")
    expect_error('null' %>% gather_object(), "1 records are not objects")

  }
)

test_that("correctly handles character(0), {}, []", {

    empty <- tbl_json(
      data.frame(
        document.id = integer(0),
        name = character(0),
        stringsAsFactors = FALSE),
      list())

    expect_identical(
      character(0) %>% gather_object,
      empty)

    expect_identical(
      '{}' %>% gather_object,
      empty
    )

    expect_error('[]' %>% gather_object)

  }
)

test_that("column.name works and doesn't clobber existing name", {

  expect_identical(
    '{"name1": 1, "name2": 2}' %>%
      as.tbl_json %>%
      mutate(name = 1L) %>%
      gather_object("new"),
    tbl_json(
      data_frame(
        document.id = rep(1L, 2),
        name = rep(1L, 2),
        new = c("name1", "name2")
      ),
      list(1L, 2L)
    )
  )

}
)

test_that("preserves a NULL column", {

  expect_identical(
    '{"name1": 1, "name2": 2}' %>%
      as.tbl_json %>%
      mutate(col = list(NULL)) %>%
      gather_object,
    tbl_json(
      data_frame(
        document.id = rep(1L, 2),
        col = rep(list(NULL), 2),
        name = c("name1", "name2")
      ),
      list(1L, 2L)
    )
  )

}
)

context("gather_keys")

test_that("gather_keys throws a warning", {

  expect_warning('{"a": 1}' %>% gather_keys)

})

test_that("gather_keys has right column name", {

  obj <- suppressWarnings('{"a": 1}' %>% gather_keys)
  expect_true("key" %in% names(obj))

})

test_that("can call repeatedly without having to change column.name", {

  expect_identical(
    suppressWarnings('{"n1": {"n2": 1}}' %>% gather_object %>% gather_object),
    tbl_json(
      data_frame(
        document.id = 1L,
        name        = "n1",
        name.2      = "n2"
      ),
      list(1L)
    )
  )

})

test_that("gather_array called multiple times throws a warning", {

  expect_warning('{"n1": {"n2": 1}}' %>% gather_object %>% gather_object)

})
