require 'spec_helper'

describe MoviesController do
  #fixtures :movies
  before :each do
    # for happy path
    @fake_movie = double('star war', :id => '1', :title => 'Star Wars', :rating => 'PG', :director => 'George Lucas', :release_date => '1977-05-25')
    # fake a find class method and return @fake_movie when it is called in :update
  	Movie.stub(:find).with('1').and_return(@fake_movie)
  	# for sad path
  	@empty_movie = double('Movie_dummy', :id => '2', :director => '', :title => "dummy")
    Movie.stub(:find).with('2').and_return(@empty_movie)
  end
  describe 'add director info to a existing movie' do
    it 'should call update_attribute and redirect to new movie page' do 
      # @fake_movie is not really a model object, so we need to fake a model method update_attributes since it will be called in :update
      @fake_movie.stub(:update_attributes!)
      put :update, {:id => '1', :movie => @fake_movie}
      response.should redirect_to(movie_path(@fake_movie))
    end
  end
  
  describe 'find movie with same director happy path' do
    it 'should generate routing for similar movies' do
      expect(:post => movie_similar_path(@fake_movie.id)).
      to route_to(:controller => "movies", :action => "similar", :movie_id => '1')
    end
    it 'should call model method that find similar movies' do 
      @fake_resutls = [double('movie1'), double('movie2')]
      Movie.should_receive(:all_productions).with(@fake_movie.director).and_return(@fake_resutls)
      get :similar, {:movie_id => @fake_movie.id}
    end
    it 'should select similar movies view for rendering and make results available' do
      Movie.stub(:all_productions).and_return(@fake_movie)
      get :similar, {:movie_id => @fake_movie.id}
      expect(response).to render_template('similar')
      assigns(:movies).should == @fake_movie
    end
  end
  
  
  describe 'no director info sad path' do
    it 'should generate routing for similar movies' do
      expect(:post => movie_similar_path(@empty_movie.id)).
      to route_to(:controller => "movies", :action => "similar", :movie_id => '2')
    end
    it 'should select index view for rendering and generate a flash' do
      get :similar, {:movie_id => @empty_movie.id}
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to match "'#{@empty_movie.title}' has no director info"
    end
  end
end