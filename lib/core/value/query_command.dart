class QueryCommand {
  static String getCategoryList = '''
      query{
      categories{
        id
        title
        slug 
      }
    }
  ''';

  static String getSubscriptCategoryByUserId = '''
  
  query(\$userId:ID){
    member(where:{
      id:\$userId
    }){
      id
      name
      following_category{
        id
        title
        slug
      }
    }
  }
  ''';
}
