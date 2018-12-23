require_relative '../../../lib/entities/book'
require_relative '../../../lib/entities/highlight'
require_relative '../../../lib/repositories/books_repository'
require_relative '../../../spec/support/mongo_db_integration'

RSpec.describe KindleClippings::Repository::Books do
  before(:all) do
    @mongo_integration_support = KindleClippings::Support::MongoDbIntegration.new
  end

  before(:each) do
    @mongo_integration_support.drop_collection
  end

  after(:each) do
    @mongo_integration_support.drop_collection
  end

  after(:all) do
    @mongo_integration_support.close_connection
  end

  subject { KindleClippings::Repository::Books.new }

  let(:book) {
    KindleClippings::Book.new(book_title: 'Women', author: 'Charles Bukowski', highlights: [highlight_1])
  }
  let(:same_book_more_highlights) {
    KindleClippings::Book.new(book_title: 'Women', author: 'Charles Bukowski', highlights: [highlight_2, highlight_3])
  }
  let(:highlight_1) {
    KindleClippings::Highlight.new(content: 'Highlight content 1', location: nil, page: nil, type: nil)
  }
  let(:highlight_2) {
    KindleClippings::Highlight.new(content: 'Highlight content 2', location: nil, page: nil, type: nil)
  }
  let(:highlight_3) {
    KindleClippings::Highlight.new(content: 'Highlight content 3', location: nil, page: nil, type: nil)
  }

  describe '#upsert' do
    context 'when a document for the book does not exist in the collection' do
      it 'inserts the document for the book with the correct attributes' do
        upsert_result = subject.upsert(book)
        upserted_document = @mongo_integration_support.find(upsert_result.inserted_ids.first)

        expect(upserted_document[:_id]).to eq(upsert_result.inserted_ids.first)
        expect(upserted_document[:book_title]).to eq(book.book_title)
        expect(upserted_document[:author]).to eq(book.author)
        expect(upserted_document[:highlights].count).to eq(book.highlights.count)
      end

      it 'inserts the document with the correct highlights and attributes' do
        upsert_result = subject.upsert(book)
        upserted_document = @mongo_integration_support.find(upsert_result.inserted_ids.first)

        upserted_document[:highlights].each do |h|
          expect(h['content']).to eq(highlight_1.content)
          expect(h['location']).to eq(highlight_1.location)
          expect(h['page']).to eq(highlight_1.page)
          expect(h['type']).to eq(highlight_1.type)
        end
      end
    end

    context 'when a document for the book already exists in the collection' do
      let!(:existing_document_id) { @mongo_integration_support.insert_document(book).inserted_ids.first }

      it 'updates the existing document with the correct number of highlights' do
        subject.upsert(same_book_more_highlights)
        upserted_document = @mongo_integration_support.find(existing_document_id)

        total_count_highlights = book.highlights.count + same_book_more_highlights.highlights.count
        expect(upserted_document[:highlights].count).to eq(total_count_highlights)
      end

      it 'updates the existing document with the correct highlight attributes' do
        subject.upsert(same_book_more_highlights)
        upserted_document = @mongo_integration_support.find(existing_document_id)

        expect(upserted_document[:highlights][0]['content']).to eq(highlight_1.content)
        expect(upserted_document[:highlights][0]['location']).to eq(highlight_1.location)
        expect(upserted_document[:highlights][0]['page']).to eq(highlight_1.page)
        expect(upserted_document[:highlights][0]['type']).to eq(highlight_1.type)

        expect(upserted_document[:highlights][1]['content']).to eq(highlight_2.content)
        expect(upserted_document[:highlights][1]['location']).to eq(highlight_2.location)
        expect(upserted_document[:highlights][1]['page']).to eq(highlight_2.page)
        expect(upserted_document[:highlights][1]['type']).to eq(highlight_2.type)

        expect(upserted_document[:highlights][2]['content']).to eq(highlight_3.content)
        expect(upserted_document[:highlights][2]['location']).to eq(highlight_3.location)
        expect(upserted_document[:highlights][2]['page']).to eq(highlight_3.page)
        expect(upserted_document[:highlights][2]['type']).to eq(highlight_3.type)
      end
    end
  end
end
