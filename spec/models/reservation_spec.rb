require 'rails_helper'

RSpec.describe Reservation, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @store = FactoryBot.create(:store)
    @seat = FactoryBot.create(:seat, store: @store)
    @reservation = FactoryBot.build(:reservation, user: @user, seat: @seat)
  end

  describe '座席の予約' do
    context '予約できる場合' do
      it '予約できる' do
        expect(@reservation).to be_valid
      end
    end

    context '予約できない場合' do
      it '予約日時がない場合' do
        @reservation.start_time = ''
        @reservation.valid?
        expect(@reservation.errors.full_messages).to include("Start time can't be blank")
      end

      it '人数が記載されていない場合' do
        @reservation.num_people = ''
        @reservation.valid?
        expect(@reservation.errors.full_messages).to include("Num people can't be blank")
      end


      it '電話番号がない場合' do
        @reservation.phone_number = ''
        @reservation.valid?
        expect(@reservation.errors.full_messages).to include("Phone number can't be blank")
      end

      it '電話番号の数字が全角の場合' do
        @reservation.phone_number = '０１２３４５６７８９'
        @reservation.valid?
        expect(@reservation.errors.full_messages).to include("Phone number は10〜11桁の半角数字で入力してください")
      end

      it '電話番号が10桁未満の場合' do
        @reservation.phone_number = '090123456'
        @reservation.valid?
        expect(@reservation.errors.full_messages).to include("Phone number は10〜11桁の半角数字で入力してください")
      end

      it '電話番号が11桁より多い場合' do
        @reservation.phone_number = '090123456789'
        @reservation.valid?
        expect(@reservation.errors.full_messages).to include("Phone number は10〜11桁の半角数字で入力してください")
      end

      it '電話番号が半角数字で入力されていない場合' do
        @reservation.phone_number = '090あいうえお'
        @reservation.valid?
        expect(@reservation.errors.full_messages).to include("Phone number は10〜11桁の半角数字で入力してください")
      end

      it 'すでに予約が入っている場合' do
        @reservation.save
        another_reservation = FactoryBot.build(:reservation, seat: @seat)
        another_reservation.save
        expect(another_reservation.errors.full_messages).to include("Start time はすでに予約が入っています")
      end
    end
  end
end
